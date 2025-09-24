solveInParallelSteadyState <- function(max_runs_per_batch,
                            nCores,
                            emissions_data,
                            correlations = NULL, 
                            LHSsamples_path = "data/scaledLHSsamples.RDS",
                            world_path = "data/World.RDS"
                            ) {
  
  ###################### Input Validation
  if (is.null(max_runs_per_batch)) {
    stop("Error: max_runs_per_batch cannot be NULL. Please provide a valid value.")
  }
  if (is.null(nCores)) {
    stop("Error: nCores cannot be NULL. Please provide a valid number of cores.")
  }
  if (is.null(emissions_data)) {
    stop("Error: emissions_data cannot be NULL. Please provide a valid emissions dataset.")
  }
  
  ###################### Step 1: load the scaled LHS samples
  LHSsamples <- readRDS(LHSsamples_path)
  
  ###################### Step 2: Prepare emissions and LHS samples for parallel solving
  
  # Number of runs in the LHS matrix
  total_runs <- ncol(LHSsamples)
  
  # Determine the number of batches and how runs are distributed across them
  max_runs_per_batch <- max_runs_per_batch
  nbatches <- total_runs %/% max_runs_per_batch
  extra_runs <- total_runs %% max_runs_per_batch
  
  if (extra_runs != 0) {
    nbatches <- nbatches + 1
  }
  
  # Add runs per batch to a vector
  runs_distribution <- rep(max_runs_per_batch, nbatches)
  
  if (extra_runs != 0) {
    # Override the last batch to fit the remaining runs
    runs_distribution[length(runs_distribution)] <- extra_runs
  }
  
  # Split emissions data into chunks using the runs_distribution
  emis_slices <- list()
  start_index <- 1
  for (runs in runs_distribution) {
    end_index <- start_index + runs - 1
    emis_slices[[length(emis_slices) + 1]] <- emissions_data[emissions_data$RUN %in% (start_index:end_index), ]
    start_index <- end_index + 1
  }
  
  # Slice the LHS samples into chunks, matching the batch distribution
  LHS_slices <- list()
  start_index <- 1
  for (run in runs_distribution) {
    end_index <- start_index + run - 1
    # Ensure we don't exceed the total number of columns in the LHSsamples matrix
    slice <- LHSsamples[, start_index:min(end_index, total_runs), drop = FALSE]
    colnames(slice) <- colnames(LHSsamples)[start_index:min(end_index, total_runs)]
    LHS_slices[[length(LHS_slices) + 1]] <- slice
    start_index <- end_index + 1
  }
  
  ###################### Step 3: Solve in parallel
  
  # Number of slices
  nSlices <- length(emis_slices)
  
  # Create a parallel cluster
  cl <- makeCluster(nCores)
  registerDoParallel(cl)
  
  # Define the worker function for each slice
  processSlice <- function(i) {
    # Source the fakeLib inside each worker to ensure all functions are available
    source("baseScripts/fakeLib.R")
    
    # Load a fresh instance of World to avoid mutability issues
    localWorld <- readRDS(world_path)
    
    if(is.null(correlations)){
      # Perform computations using `Solve`
      localWorld$Solve(emissions = emis_slices[[i]], 
                     LHSmatrix = LHS_slices[[i]], 
                     nRUNs = length(unique(emis_slices[[i]]$RUN)))
    } else {
      # Perform computations using `Solve`
      localWorld$Solve(emissions = emis_slices[[i]], 
                       LHSmatrix = LHS_slices[[i]], 
                       nRUNs = length(unique(emis_slices[[i]]$RUN)),
                       correlations = correlations)
    }
    
    # Collect and return results
    result_list <- list(
      SliceID = i,
      Masses = localWorld$Masses(),
      Concentrations = localWorld$Concentration(),
      Emissions = localWorld$Emissions(),
      Variables = localWorld$VariableValues()
    )
    
    return(result_list)
  }
  
  # Execute in parallel using foreach
  combinedResults <- foreach(i = seq_len(nSlices)) %dopar% {
    processSlice(i)
  }
  
  # Stop the cluster
  stopCluster(cl)
  
  ###################### Step 4: Combine the outcomes into one list
  
  massesCombined <- do.call(rbind, lapply(combinedResults, `[[`, "Masses"))
  concentrationsCombined <- do.call(rbind, lapply(combinedResults, `[[`, "Concentrations"))
  emissionsCombined <- do.call(rbind, lapply(combinedResults, `[[`, "Emissions"))
  variablesCombined <- do.call(rbind, lapply(combinedResults, `[[`, "Variables"))
  
  # Combine all into a single result list
  Solution <- list(
    Masses = massesCombined,
    Concentrations = concentrationsCombined,
    Emissions = emissionsCombined,
    Variables = variablesCombined
  )
  
  return(Solution)
}

solveInParallelDynamic <- function(max_runs_per_batch,
                                   nCores,
                                   emissions_data, 
                                   tmin, 
                                   tmax, 
                                   nTIMES,
                                   correlations = NULL,
                                   LHSsamples_path = "data/scaledLHSsamples.RDS", 
                                   world_path = "data/World.RDS"
                                   ) {

  ###################### Input Validation
  if (is.null(max_runs_per_batch)) {
    stop("Error: max_runs_per_batch cannot be NULL. Please provide a valid value.")
  }
  if (is.null(nCores)) {
    stop("Error: nCores cannot be NULL. Please provide a valid number of cores.")
  }
  if (is.null(emissions_data)) {
    stop("Error: emissions_data cannot be NULL. Please provide a valid emissions dataset.")
  }
  if (is.null(tmin)) {
    stop("Error: tmin cannot be NULL. Please provide a valid value.")
  }
  if (is.null(tmax)) {
    stop("Error: tmax cannot be NULL. Please provide a valid value.")
  }
  if (is.null(nTIMES)) {
    stop("Error: nTIMES cannot be NULL. Please provide a valid value.")
  }

  ###################### Step 1: Load the scaled samples
  LHSsamples <- readRDS(LHSsamples_path)
  
  ###################### Step 2: Prepare emissions and LHS samples for parallel solving
  
  # Divide the emissions and LHS samples over different lists as evenly as possible for parallel solving
  total_runs <- ncol(LHSsamples)
  max_runs_per_batch <- max_runs_per_batch
  
  nbatches <- total_runs %/% max_runs_per_batch
  extra_runs <- total_runs %% max_runs_per_batch
  
  if (extra_runs != 0) {
    nbatches <- nbatches + 1
  }
  
  # Initialize a vector to store the number of runs per core
  runs_distribution <- rep(max_runs_per_batch, nbatches)
  
  if (extra_runs != 0) {
    # Overwrite the last batch with the number in extra_runs
    runs_distribution[length(runs_distribution)] <- extra_runs
  }
  
  # Split emissions data into chunks based on computed runs_distribution
  emis_slices <- list()
  start_index <- 1
  for (runs in runs_distribution) {
    end_index <- start_index + runs - 1
    emis_slices[[length(emis_slices) + 1]] <- emissions_data[emissions_data$RUN %in% (start_index:end_index), ]
    start_index <- end_index + 1
  }
  
  # Slice LHS samples based on runs_distribution
  LHS_slices <- list()
  start_index <- 1
  for (run in runs_distribution) {
    end_index <- start_index + run - 1
    # Ensure we don't exceed the total number of columns in the LHS data
    slice <- LHSsamples[, start_index:min(end_index, total_runs), drop = FALSE]
    colnames(slice) <- colnames(LHSsamples)[start_index:min(end_index, total_runs)]
    LHS_slices[[length(LHS_slices) + 1]] <- slice
    start_index <- end_index + 1
  }
  
  ###################### Step 3: Solve in parallel
  nSlices <- length(emis_slices)
  
  cl <- makeCluster(nCores)
  registerDoParallel(cl)
  
  processSlice <- function(i) {
    # Source required scripts
    source("baseScripts/fakeLib.R")
    
    # Load World object
    localWorld <- readRDS(world_path)
    
    if(is.null(correlations)){
      # Perform computations
      localWorld$Solve(
        emissions = emis_slices[[i]], 
        LHSmatrix = LHS_slices[[i]], 
        nRUNs = length(unique(emis_slices[[i]]$RUN)),
        tmin = tmin,
        tmax = tmax,
        nTIMES = nTIMES)
    } else {
      # Perform computations
      localWorld$Solve(
        emissions = emis_slices[[i]], 
        LHSmatrix = LHS_slices[[i]], 
        nRUNs = length(unique(emis_slices[[i]]$RUN)),
        tmin = tmin,
        tmax = tmax,
        nTIMES = nTIMES,
        correlations= correlations)
    }
    
    # Return results
    result_list <- list(
      SliceID = i,
      Masses = localWorld$Masses(),
      Concentrations = localWorld$Concentration(),
      Emissions = localWorld$Emissions(),
      Variables = localWorld$VariableValues()
    )
    return(result_list)
  }
  
  # Define parallel execution and combine results with `foreach`
  combinedResults <- foreach(i = seq_len(nSlices)) %dopar% {
    processSlice(i)
  }
  
  stopCluster(cl)
  
  ###################### Step 4: Combine the outcomes into one list
  massesCombined <- do.call(rbind, lapply(combinedResults, `[[`, "Masses"))
  concentrationsCombined <- do.call(rbind, lapply(combinedResults, `[[`, "Concentrations"))
  emissionsCombined <- do.call(rbind, lapply(combinedResults, `[[`, "Emissions"))
  variablesCombined <- do.call(rbind, lapply(combinedResults, `[[`, "Variables"))
  
  Solution <- list(
    Masses = massesCombined,
    Concentrations = concentrationsCombined,
    Emissions = emissionsCombined,
    Variables = variablesCombined
  )
  
  return(Solution)
}
