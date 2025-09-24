
#' @title AddAbbreviationsSBxlsx
#' @name AddAbbreviationsSBxlsx
#' @description Returns a table, default for World$kaas with two new columns to and from with the Abbrevaition of each SimpleBox compartment
#' @param kaas table with columns toSpecies, toSubCompart and toScale, idem from...
#' @param SubcompartmentsMap names character vector with the abreviations for each SubCompart
#' @param ScalesMap names character vector with the abreviations for each Scale
#' @param SpeciesMap names character vector with the abreviations for each Species
#' @return Table with standard SimpleBox abbreviations for each compartment
#' @export
f_AddAbbreviationsSBxlsx <- function(kaas = as_tibble(World$kaas), # table with columns to... and from...
                                   SubcompartmentsMap = # all subcompartments defined for SBoo
                                     c("marinesediment" = "sd2",
                                       "freshwatersediment" = "sd1",
                                       "lakesediment" = "sd0",
                                       "agriculturalsoil" = "s2",
                                       "naturalsoil" = "s1",
                                       "othersoil" = "s3",
                                       "air" = "a",
                                       "deepocean" = "w3",
                                       "sea" = "w2",
                                       "river" = "w1",
                                       "lake" = "w0",
                                       "cloudwater" = "cw"), 
                                   ScalesMap = # all scales defined for SBoo
                                     c("Arctic" = "A",
                                       "Moderate" = "M",
                                       "Tropic" = "T",
                                       "Continental" = "C",
                                       "Regional" = "R"), 
                                   SpeciesMap = # all species defined for SBoo
                                     c("Dissolved" = "D",
                                       "Gas" = "G",
                                       "Large" = "P",
                                       "Small" = "A",
                                       "Solid" = "S",
                                       "Unbound" = "U")
) {
  
  kaas <- kaas |> mutate(
    from = paste0(
      SubcompartmentsMap[fromSubCompart],
      ScalesMap[fromScale],
      SpeciesMap[fromSpecies]
    ),
    to = paste0(
      SubcompartmentsMap[toSubCompart],
      ScalesMap[toScale],
      SpeciesMap[toSpecies]
    )
  )
  
  # kaas <-
  #   kaas |>
  #   mutate(
  #     from =
  #       ifelse((fromScale == "Tropic" | fromScale == "Arctic" | fromScale == "Moderate") &
  #                (fromSubCompart == "marinesediment" | fromSubCompart == "naturalsoil"),
  #              str_replace_all(from, c("sd2" = "sd", "s1" = "s")),
  #              from
  #       )
  #   ) |>
  #   mutate(to = ifelse((toScale == "Tropic" | toScale == "Arctic" | toScale == "Moderate") &
  #                        (toSubCompart == "marinesediment" | toSubCompart == "naturalsoil"), str_replace_all(to, c("sd2" = "sd", "s1" = "s")), to))
  # 
  return(kaas)
}


#' @title Using variable name and vector of values use mutateVars
#' @name f_MutateHelper
#' @description Applies the mutateVars sequence of data based on fetchData.
#' Make sure to set the correct vector of values, as not checks are done on value versus dimension!!!
#' @param varName name of variable
#' @param varData vector of values to change to (in units for input!! use World$fetchDataUnits("landFRAC"), if unsure)
#' @return mutated variable table
#' @export
f_MutateHelper <- function(varName = "landFRAC",
                           varData = c(0.6000, 0.0050, 0.2700, 0.1000, 0.0250, 0.6000, 0.0050, 0.2700, 0.1000, 0.0250)){
  varWorld <- World$fetchData(varName)
  varWorld[,varName] <- varData
  varWorld <-
    varWorld |> pivot_longer(cols = varName,
                             names_to = "varName",
                             values_to = "Waarde")
  World$mutateVars(varWorld)
  World$UpdateDirty(varName)
  return(World$fetchData(varName))
}

################################################################################
# Script for installing SBoo and SBooScript                                    #
#                                                                              #
# This script installs SBoo and SBooScripts in a                               #
# folder of your choosing.                                                     #
#                                                                              #
# Authors: Anne Hids and Joris Quik                                            #
# Last updated: 18-08-2025                                                      # 
################################################################################

# Specify where the downloaded versions of sboo and sbooscripts should be saved to --
# this is the only change you need to make to this script. 
# dest_folder <- NULL


# you can specify a tag
# tag <- "2025.04.0"
# or if
# tag = NA
# The devBranch name is used, default is development branch which contains latest updates.

InstallSBoo <- function(Release_SBoo = "2025.04.0", # tag for release use NA for branch
                        Release_SBooScripts = "2025.04.0", # tag for release use NA for branch
                        devBranch_SBoo = "development",
                        devBranch_SBooScripts = "development",
                        Temp_Folder = "C:/Temp" # an existing folder where SimpleBox is to be installed
){
  
  # prepare directories:
  
  empty_folder <- function(target_folder){
    if (dir.exists(target_folder)) {
      items <- list.files(target_folder, full.names = TRUE, recursive = FALSE)
      if (length(items) > 0) {
        unlink(items, recursive = TRUE, force = TRUE)
      }
    }
  }
  
  if(dir.exists(paste0(Temp_Folder,"SBzips"))){
    oldfiles <- list.files(paste0(Temp_Folder,"/SBzips"), full.names = TRUE)
    file.remove(oldfiles)
    print("Old SBoo zipfiles deleted")
  }
  
  if(!dir.exists(paste0(Temp_Folder,"SBzips"))){
    dir.create(paste0(Temp_Folder,"SBzips"))
    print(paste0("Directory: ", Temp_Folder,"SBzips", " created."))
  } else print("SBzips directory already exists")
  
  empty_folder(target_folder = paste0(Temp_Folder, "SimpleBox"))
  
  # download files and unzip
  
  if(is.na(Release_SBooScripts)){
    SBScriptsLink_Release <-
      paste0("https://github.com/rivm-syso/SBooScripts/archive/refs/heads/",devBranch_SBooScripts,".zip")
    download.file(SBScriptsLink_Release,paste0(Temp_Folder,"SBzips/SBooScripts_",devBranch_SBooScripts,".zip"))
    zipfile <- paste0(Temp_Folder,"SBzips/SBooScripts_", devBranch_SBooScripts,".zip")
    # file.exists(zipfile)
    destination <- paste0(Temp_Folder, "SimpleBox")
    unzip(zipfile, exdir = destination)
    
    file.rename(file.path(destination, paste0("SBooScripts-", devBranch_SBooScripts)), 
                file.path(destination, "SBooScripts"))
  } else{
    SBScriptsLink_Release <-
      paste0("https://github.com/rivm-syso/SBooScripts/archive/refs/tags/",Release_SBooScripts,".zip")
    download.file(SBScriptsLink_Release,paste0(Temp_Folder,"/SBzips/SBooScripts_",Release_SBooScripts,".zip"))
    zipfile <- paste0(Temp_Folder,"SBzips/SBooScripts_", Release_SBooScripts,".zip")
    # file.exists(zipfile)
    destination <- paste0(Temp_Folder, "SimpleBox")
    unzip(zipfile, exdir = destination)
    
    file.rename(file.path(destination, paste0("SBooScripts-", Release_SBooScripts)), 
                file.path(destination, "SBooScripts"))
  }
  
  if(is.na(Release_SBoo)){
    SBooLink_Release <-
      paste0("https://github.com/rivm-syso/SBoo/archive/refs/heads/",devBranch_SBoo,".zip")
    
    download.file(SBooLink_Release,paste0(Temp_Folder,"SBzips/SBoo_",devBranch_SBoo,".zip"))
    
    zipfile <- paste0(Temp_Folder,"SBzips/SBoo_",devBranch_SBoo,".zip")
    # file.exists(zipfile)
    destination <- paste0(Temp_Folder, "SimpleBox")
    unzip(zipfile, exdir = destination)
    
    file.rename(file.path(destination, paste0("SBoo-", devBranch_SBoo)), 
                file.path(destination, "SBoo"))
  } else{
    SBooLink_Release <-
      paste0("https://github.com/rivm-syso/SBoo/archive/refs/tags/",Release_SBoo,".zip")
    
    download.file(SBooLink_Release,paste0(Temp_Folder,"SBzips/SBoo_",Release_SBoo,".zip"))
    
    zipfile <- paste0(Temp_Folder,"SBzips/SBoo_",Release_SBoo,".zip")
    # file.exists(zipfile)
    destination <- paste0(Temp_Folder, "SimpleBox")
    unzip(zipfile, exdir = destination)
    
    file.rename(file.path(destination, paste0("SBoo-", Release_SBoo)), 
                file.path(destination, "SBoo"))
  }
  
  # Remove SB zip files
  unlink(paste0(Temp_Folder, "SBzips"), recursive = TRUE)
  
  return(paste0("The SimpleBox model can be found in ", destination))
}