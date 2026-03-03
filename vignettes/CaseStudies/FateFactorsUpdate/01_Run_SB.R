#marine currents SB run
library(tidyverse)
library(openxlsx)
setwd("~/Documents/GitHub/SBooScripts")
# Read csvs
plastic_values <- read.xlsx("vignettes/CaseStudies/FateFactorsUpdate/SI_3_Fate.xlsx", sheet = "Polymer_list") 
regions <- read.xlsx("vignettes/CaseStudies/FateFactorsUpdate/SI_3_Fate.xlsx", sheet = "4.1.Regio_param") 
colnames(regions) <- regions[2,]
regions_rows = nrow(regions)
#Import the data with regionalization. Some variables are left as the default input of SBoo
#If no variable is provided in the regio sheet, the default value is kept
regions <- regions |>
  slice(3:regions_rows)|>
  filter(!is.na(Variable)) |>
  dplyr::select(Variable, Scale, SubCompart, `North America`, `Latin America`, Europe, 
         `Africa & Middle East`, `Central Asia`, `Southeast Asia`, `Northern regions`, `Oceania`) |>
  rename(varName = Variable)

# Initalize World
source("baseScripts/initWorld_onlyPlastics.R")

#If Test FALSE: new version of SB, if True, then the old version (excel)
#World$SetConst(Test = "TRUE")
World$SetConst(Regional_and_Continental_deepocean = "TRUE")
World$SetConst(Remove_global = "TRUE") #if true, remove flows to moderate, arctic and tropic
World$UpdateKaas(mergeExisting = FALSE)

# Change global landscape properties - make scales really small to remove them
#In this case, the continental scale of SBoo IS USED AS THE GLOBAL -  and the regional is used as the continental
#it is because SBoo has 3 different global regions, and a regional, which we don't need in LCIA
#So regional(SBoo)=continental(LCIA) and continental(SBoo)=global(LCIA)
global_df <- data.frame(varName = c("TotalArea", "TotalArea", "TotalArea","FRACsea"), 
                        Scale = c("Arctic", "Moderate", "Tropic", "Moderate"),
                        Waarde = c(10^-20,  502268688752959+1 , 10^-20, 0.7244500823950340000000000000)) 
#The continental and regional are nested in the moderate scale. TotalArea needs to be the some of comp+nested comp.

World$mutateVars(global_df)
World$UpdateDirty(unique(global_df$varName))

#remove flows to moderate, artic, tropic
global_df <- data.frame(varName = c("x_FromModerate2ArctWater", " x_OceanMixing2Deep", "x_OceanMixing2Sea","FRACsea"), 
                        #fromScale = c("Moderate", "Moderate", "Tropic", "Moderate"),
                        Waarde = c(10^-20,  10^-20, 10^-20, 0.7244500823950340000000000000)) 
#The continental and regional are nested in the moderate scale. TotalArea needs to be the sum of comp+nested comp.

World$mutateVars(global_df)
World$UpdateDirty(unique(global_df$varName))


#remove flows to moderate, arctic, tropic
airflow_df <- data.frame(varName = c("AirFlow", "AirFlow", "AirFlow"), 
                        Scale = c("Arctic", "Moderate", "Tropic"),
                        Waarde = c(10^-20,  10^-20, 10^-20)) 
World$mutateVars(airflow_df)
World$UpdateDirty(unique(airflow_df$varName))

#remove flows to moderate, artic, tropic
current_df <- data.frame(varName = c("OceanCurrent"), 
                        #fromScale = c("Arctic", "Moderate", "Tropic"),
                        Waarde = c(10^-20)) 
#The continental and regional are nested in the moderate scale. TotalArea needs to be the some of comp+nested comp.


#remove flows to moderate, artic, tropic
current_df <- data.frame(varName = c("x_ToModerateWater"), 
                         fromScale = c("Continental"),
                         Waarde = c(10^-20)) 
#The continental and regional are nested in the moderate scale. TotalArea needs to be the some of comp+nested comp.

World$mutateVars(current_df)
World$UpdateDirty(unique(current_df$varName))

#Set the interception in soil
intercept_df <- data.frame(varName = c("VegInterceptFrac"), 
                         Waarde = c(0.975,0.975,0.975)) 
#The continental and regional are nested in the moderate scale. TotalArea needs to be the some of comp+nested comp.

World$mutateVars(intercept_df)
World$UpdateDirty(unique(intercept_df$varName))

#Change the drag method to Dioguardi 2018
DragMethod_df <- data.frame(varName = "DragMethod",
                       Waarde = "Bagheri")
World$mutateVars(DragMethod_df)
World$UpdateDirty(unique(DragMethod_df$varName))

global_df <- data.frame(varName = c("VertDistance", "VertDistance", "VertDistance", "VertDistance", "VertDistance", "VertDistance"), 
                        SubCompart = c("freshwatersediment","lakesediment","marinesediment","naturalsoil","agriculturalsoil","othersoil"),
                        #Scale = c("Continental","Regional"),
                        Waarde = c(0.1, 0.1, 0.1, 0.1, 0.1, 0.1)) #Set the depth of all sediments and soil to 10cm, as per USEtox

World$mutateVars(global_df)
World$UpdateDirty(unique(global_df$varName))

#Remove fragmentation
kfrag_df <- data.frame(varName = c("kfrag"), 
                       #SubCompart = c("freshwatersediment","lakesediment","marinesediment","naturalsoil","agriculturalsoil"),
                       #Species = c("Continental","Regional"),
                       Waarde = c(0))
World$mutateVars(kfrag_df)
World$UpdateDirty(unique(kfrag_df$varName))

vars_to_update = c()

# Loop over regions
region_names <- colnames(regions)[4:11]
polymer_names <- colnames(plastic_values)[3:ncol(plastic_values)]

#### emission compartments, volumes, SDF, etc needed for CF calculation
sizes <- c(1,10,100,1000,5000) #D will be divided by 2
shapes <- c("Sphere","Fiber","Film")
time_horizon=20 #[yrs] time horizon for dynamic solver (Time over which impacts are integrated for )
#list of possible emission compartments to loop over
#only SOLID
emission_compartments <- c("aRS","w1RS","w0RS","w2RS","sd1RS","sd0RS","sd2RS","s1RS","s2RS",
                           "aCS","w1CS","w0CS","w2CS","sd1CS","sd0CS","sd2CS","s1CS","s2CS") 

receiving_compartments <- c("aRS","w1RS","w0RS","w2RS", "w3RS","sd1RS","sd0RS","sd2RS","s1RS","s2RS",
                            "aCS","w1CS","w0CS","w2CS", "w3CS","sd1CS","sd0CS","sd2CS","s1CS","s2CS") 

#Exposure and effect factors for microplastics in air, water, sediments and soil, expressed in PAF.m3/kg
EEF_air = 0 #so far not quantified
EEF_w = 1067.5 #Corella-Puertas et al. (2023) 
EEF_sed = 16.17 #Saadi et al. 2025 
EEF_s = 0.54 #Tunali & Nowack (2025) derived an EEF of chronic EC10 values of 0.79PAF.kg/g, which converts to 0.54 PAF.m3/kg using a soil density of 1460 kg/m3
SF=1 #severity factor, PAF to PDF (Oginah et al., 2025)

eef_compartments <- c(EEF_air, EEF_w, EEF_w, EEF_w, EEF_w, EEF_sed, EEF_sed, EEF_sed, EEF_s, EEF_s,
                      EEF_air, EEF_w, EEF_w, EEF_w, EEF_w, EEF_sed, EEF_sed, EEF_sed, EEF_s, EEF_s)

### fraction of species in each compartment
FracSpe_w_marine = 0.4458 #fraction of marine species feeding in water - Saadi et al., 2025
FracSpe_sed_marine = 1-FracSpe_w_marine #fraction of marine species feeding in the sediment - Saadi et al., 2025
FracSpe_ws_marine = FracSpe_w_marine*0.662 #fraction of marine species feeding in the water surface - Hajjar et al., 2025
FracSpe_wc_marine = FracSpe_w_marine*(1-0.662) #fraction of marine species feeding in the water column - Hajjar et al., 2025
FracSpe_river = 0.7385 #fraction of aquatic species living in rivers - IUCN Red List, 2024
FracSpe_lake = 1-FracSpe_river #fraction of aquatic species living in lakes - IUCN Red List, 2024
FracSpe_wc_aqua = 0.2989 #fraction of aquatic species living in water column - Schmidt-Kloiber et al., 2024
FracSpe_sed_aqua = 0.7011 #fraction of aquatic species living in sediments - Schmidt-Kloiber et al., 2024
FracSpe_nat_soil = 0.7031 #BDM, 2015
FracSpe_agr_soil = 0.2969 #BDM, 2015

#ReCiPe number of species:
tot_num_species_marine = 250000
tot_num_species_fresh = 150000
tot_num_species_terr = 1600000
list_tot_species = c(tot_num_species_marine, tot_num_species_fresh, tot_num_species_terr)
####


# Get the names and abbreviations of all compartments
states <- World$states$asDataFrame
count <- 0
results_FF <- data.frame(region = character(),
                      polymer = character(),
                      size = integer(),
                      shape = character(),
                      emission_compartment = character(),
                      Scale = character(),
                      SubCompart = character(),
                      FF = numeric())

results_CF_mid_PAF_day <- data.frame(region = character(),
                             polymer = character(),
                             size = integer(),
                             shape = character(),
                             emission_compartment = character())

results_CF_end_PDF_year <- data.frame(region = character(),
                            polymer = character(),
                            size = integer(),
                            shape = character(),
                            emission_compartment = character())

results_CF_end_species_year <- data.frame(region = character(),
                                      polymer = character(),
                                      size = integer(),
                                      shape = character(),
                                      emission_compartment = character())

results_CF_end_PDF_m2_year  <- data.frame(region = character(),
                                          polymer = character(),
                                          size = integer(),
                                          shape = character(),
                                          emission_compartment = character(),
                                          Scale = character()
                                          )

#####Loading bar
n <- length(region_names) * length(polymer_names) * length(sizes) * length(shapes) * length(emission_compartments)
pb <- txtProgressBar(min = 0, max = n, style = 3)
count <- 0

#####TEST
#Variables to test
#reg = "Ocenia"
reg = "North America"
pol = "LDPE"
size = 5000
shape = "Sphere"
emission_compartment = "sd2CS"

#### LOOPS

for(reg in region_names){
  region_df <- regions[, c("varName", "Scale", "SubCompart", reg)]
  names(region_df)[ncol(region_df)] <- "Waarde"

  region_df <- region_df |>
    mutate(Waarde = as.numeric(Waarde))

  World$mutateVars(region_df)
  World$UpdateDirty(unique(region_df$varName))
  #vars_to_update <- unique(region_df$varName) 
  
  #Retrieve the volume of each receiving compartment defined
  df_volumes <- World$fetchData("Volume")
  states_with_vol <- states %>% # join states with df_volumes to retrieve volume based on their code name (w1RS, etc)
    left_join(df_volumes, by = c("Scale", "SubCompart"))
  # now filter only receiving compartments of interest
  volume_compartments <- states_with_vol %>%
    filter(Abbr %in% receiving_compartments, Species == "Solid") %>%   # keep only Solid
    arrange(factor(Abbr, levels = receiving_compartments)) %>%         # keep original order
    pull(Volume)
  
  #compartment_table <- data.frame( compartment = receiving_compartments, 
   #                                EEF = eef_compartments, 
    #                               volume =  volume_compartments)
  
  df_areas <- World$fetchData("Area")
  states_with_area <- states %>% # join states with df_areas to retrieve volume based on their code name (w1RS, etc)
    left_join(df_areas, by = c("Scale", "SubCompart"))
  # now filter only receiving compartments of interest
  areas_compartments <- states_with_area %>%
    filter(Abbr %in% receiving_compartments, Species == "Solid") %>%   # keep only Solid
    arrange(factor(Abbr, levels = receiving_compartments)) %>%         # keep original order
    pull(Area)
  
  #remove flows to moderate, arctic, tropic
  airflow_df <- data.frame(varName = c("AirFlow", "AirFlow", "AirFlow"), 
                           Scale = c("Arctic", "Moderate", "Tropic"),
                           Waarde = c(10^-20,  10^-20, 10^-20)) 
  World$mutateVars(airflow_df)
  World$UpdateDirty(unique(airflow_df$varName))
  
  
  ### SDF matrix for that region
  FracSpe_C_marine <- World$fetchData("dens_marine_species_C") #fraction of marine species living in continental sea water - Tittensor et al., 2010
  FracSpe_G_marine <- World$fetchData("dens_marine_species_RoW") #fraction of marine species living in global sea water - Tittensor et al., 2010
  FracSpe_C_aqua <- World$fetchData("dens_fw_species_C") #density of species living in continent - IUCN Red List, 2024
  FracSpe_G_aqua <- World$fetchData("dens_fw_species_RoW") #density of species living in the rest of the world  IUCN Red List, 2024
  FracSpe_C_ter <- World$fetchData("dens_ter_species_C") #density of species living in continent - IUCN Red List, 2024
  FracSpe_G_ter <- World$fetchData("dens_ter_species_RoW") #density of species living in the rest of the world  IUCN Red List, 2024
  
  SDF_ME_sw_ws_C = FracSpe_ws_marine*FracSpe_C_marine #seawater water surface
  SDF_ME_sw_wc_C = FracSpe_wc_marine*FracSpe_C_marine #seawater water column
  SDF_ME_sw_sed_C = FracSpe_sed_marine*FracSpe_C_marine #seawater sediments
  SDF_ME_sw_ws_G = FracSpe_ws_marine*FracSpe_G_marine #seawater water surface
  SDF_ME_sw_wc_G = FracSpe_wc_marine*FracSpe_G_marine #seawater water column
  SDF_ME_sw_sed_G = FracSpe_sed_marine*FracSpe_G_marine #seawater sediments
  
  SDF_AE_lw_C = FracSpe_lake*FracSpe_wc_aqua*FracSpe_C_aqua
  SDF_AE_lw_sed_C = FracSpe_lake*FracSpe_sed_aqua*FracSpe_C_aqua
  SDF_AE_fw_C = FracSpe_river*FracSpe_wc_aqua*FracSpe_C_aqua
  SDF_AE_fw_sed_C = FracSpe_river*FracSpe_sed_aqua*FracSpe_C_aqua
  SDF_AE_lw_G = FracSpe_lake*FracSpe_wc_aqua*FracSpe_G_aqua
  SDF_AE_lw_sed_G = FracSpe_lake*FracSpe_sed_aqua*FracSpe_G_aqua
  SDF_AE_fw_G = FracSpe_river*FracSpe_wc_aqua*FracSpe_G_aqua
  SDF_AE_fw_sed_G = FracSpe_river*FracSpe_sed_aqua*FracSpe_G_aqua
  
  SDF_TE_nat_soil_C = FracSpe_nat_soil*FracSpe_C_ter
  SDF_TE_agr_soil_C = FracSpe_agr_soil*FracSpe_C_ter
  SDF_TE_nat_soil_G = FracSpe_nat_soil*FracSpe_G_ter
  SDF_TE_agr_soil_G = FracSpe_agr_soil*FracSpe_G_ter
  # verification:
  total <- SDF_AE_lw_C + SDF_AE_lw_sed_C + SDF_AE_fw_C + SDF_AE_fw_sed_C +
    SDF_AE_lw_G + SDF_AE_lw_sed_G + SDF_AE_fw_G + SDF_AE_fw_sed_G + #fw SDF  1 
    SDF_ME_sw_ws_C + SDF_ME_sw_wc_C + SDF_ME_sw_sed_C + SDF_ME_sw_ws_G + SDF_ME_sw_wc_G + SDF_ME_sw_sed_G + #marine SDF = 1
    SDF_TE_nat_soil_C+SDF_TE_agr_soil_C+SDF_TE_nat_soil_G+SDF_TE_agr_soil_G #terrestrial SDF = 1
  
  if (abs(total - 3) > 1e-8) {
    stop("Sum of SDF_AE terms is not equal to 3. Current value: ", total)
  }
  
  # Create an empty 3x18 matrix
  tab_SDF <- matrix(0, nrow = 3, ncol = 20)
  
  # Name rows and columns
  rownames(tab_SDF) <- c("Marine_Ecosystem", "Freshwater_Ecosystem", "Terrestrial_Ecosystem")
  colnames(tab_SDF) <- c("a_C","fw_C","lw_C", "sw_ws_C", "sw_wc_C", "fw_sed_C","lw_sed_C",  "sw_sed_C",     #the order is slightly different than in Louvet et al. 20205
                         "nat_soil_C", "agr_soil_C", "a_G","fw_G","lw_G",  "sw_ws_G", "sw_wc_G", "fw_sed_G", 
                         "lw_sed_G", "sw_sed_G", "nat_soil_G", "agr_soil_G")
  # Fill the matrix with the SDFs
  SDF <- as.data.frame(tab_SDF)
  # Marine ecosystem
  SDF["Marine_Ecosystem", "sw_ws_C"]       <- SDF_ME_sw_ws_C
  SDF["Marine_Ecosystem", "sw_wc_C"]       <- SDF_ME_sw_wc_C
  SDF["Marine_Ecosystem", "sw_sed_C"]   <- SDF_ME_sw_sed_C
  SDF["Marine_Ecosystem", "sw_ws_G"]       <- SDF_ME_sw_ws_G
  SDF["Marine_Ecosystem", "sw_wc_G"]       <- SDF_ME_sw_wc_G
  SDF["Marine_Ecosystem", "sw_sed_G"]   <- SDF_ME_sw_sed_G
  # Freshwater ecosystem
  SDF["Freshwater_Ecosystem", "lw_C"]      <- SDF_AE_lw_C
  SDF["Freshwater_Ecosystem", "lw_sed_C"]  <- SDF_AE_lw_sed_C
  SDF["Freshwater_Ecosystem", "fw_C"]      <- SDF_AE_fw_C
  SDF["Freshwater_Ecosystem", "fw_sed_C"]  <- SDF_AE_fw_sed_C
  SDF["Freshwater_Ecosystem", "lw_G"]      <- SDF_AE_lw_G
  SDF["Freshwater_Ecosystem", "lw_sed_G"]  <- SDF_AE_lw_sed_G
  SDF["Freshwater_Ecosystem", "fw_G"]      <- SDF_AE_fw_G
  SDF["Freshwater_Ecosystem", "fw_sed_G"]  <- SDF_AE_fw_sed_G
  # Terrestrial ecosystem
  SDF["Terrestrial_Ecosystem", "nat_soil_C"] <- SDF_TE_nat_soil_C
  SDF["Terrestrial_Ecosystem", "agr_soil_C"] <- SDF_TE_agr_soil_C
  SDF["Terrestrial_Ecosystem", "nat_soil_G"] <- SDF_TE_nat_soil_G
  SDF["Terrestrial_Ecosystem", "agr_soil_G"] <- SDF_TE_agr_soil_G
  
  ###
  
  # Polymer loop
  for(pol in polymer_names){
    #Import the properties of that polymer from the df
    print(pol)
    polymer_df <- plastic_values[,c("varName","SubCompart",pol)]
    names(polymer_df)[ncol(polymer_df)] <- "Waarde" #rename the last column "Waarde" instead of name of pol
    polymer_df_selected <- polymer_df |>
      slice(1:19) |>
      mutate(Waarde=as.numeric(Waarde))
    
    #Set the new values for RhoS, Kssdr, CorFacSSA and MinSettVel for the specific polymer
    World$mutateVars(polymer_df_selected)
    #World$UpdateDirty(unique(polymer_df$varName))
    vars_to_update <- c(vars_to_update,unique(polymer_df_selected$varName))
    
    World$SetConst(Degrading_enzyme = polymer_df$Waarde[polymer_df$varName == "Degrading_enzyme"])
    #enzyme_df <- polymer_df %>%
     # filter(Waarde %in% c(TRUE, FALSE))
    
    #World$mutateVars(enzyme_df)
    #World$UpdateDirty(unique(polymer_df$varName))
    #vars_to_update <- c(vars_to_update,unique(enzyme_df$varName))



    #loop over size
    for (size in sizes) {
      size_df <- data.frame(varName = "RadS",
                                Waarde = size/2*1000) #convert D to R and convert um to nm (SBoo takes RadS as nm)

      World$mutateVars(size_df)
      #World$UpdateDirty(unique(variable_df$varName))
      vars_to_update <- c(vars_to_update,unique(size_df$varName))

      #Loop over shape
      for (shape in shapes) {
        
        #Define the dimensions of the microplastics emissions (not just diameter or thickness) - SB input is um for sides
        if (shape == "Sphere" | shape == "Default") {
          Longest_side <- size #Here size = diameter
          Intermediate_side <- size 
          Shortest_side <- size 
        } else if (shape == "Ellipsoid") {
          Longest_side <- size 
          Intermediate_side <- size 
          Shortest_side <- size
        } else if (shape == "Cube" | shape == "Box" | shape == "Film") {
          Shortest_side <- size #Thickness
          Intermediate_side <- Shortest_side * 30 #Kooi & Koelmans (2019): SI
          if (Shortest_side < 100 ) {
            Longest_side <- Shortest_side*100 
          } else {
            Longest_side <- Shortest_side*30
          }
        } else if (shape == "Cylindric - circular" | shape == "Fiber") {
          Shortest_side <- size 
          Intermediate_side <- Shortest_side #equal for fibers
          if (Shortest_side == 1 ) {
            Longest_side <- Shortest_side*50 
          } else if (Shortest_side == 1000) {
            Longest_side <- Shortest_side*5 #stay in the microplastics range
          } else{
            Longest_side <- Shortest_side*10
          }
        } else if (shape == "Cylindric - elliptic") {
          Longest_side <- size
          Intermediate_side <- size
          Shortest_side <- size
        } else {
          return("Invalid shape! Please choose from Sphere, Ellipsoid, Cube, Box, Cylindric - circular, or Cylindric - elliptic.")
        }
        
        if (Shortest_side > 5000 || Intermediate_side > 5000 || Longest_side > 5000) {
          next  # Skip if one of the dimensions exceeds the microplastics range
        }
        
        shape_df <- data.frame(varName = "Shape", Waarde = as.character(shape))
        dimensions_df <- data.frame(
          varName = c("Shortest_side", "Intermediate_side", "Longest_side"),
          Waarde = c(Shortest_side, Intermediate_side, Longest_side)
        )
        World$mutateVars(shape_df)
        World$mutateVars(dimensions_df)
        #World$UpdateDirty(unique(c(shape_df$varName, dimensions_df$varName)))
        
        vars_to_update <- c(vars_to_update,unique(shape_df$varName),unique(dimensions_df$varName))
        
        #UpdateDirty with the names of all variables that were changed, in all the loops
        World$UpdateDirty(vars_to_update)
        k_matrix = World$exportEngineR()
        k_detailed = World$fetchData("kaas")
        
  
        #loop over emission compartments
        for (emission_compartment in emission_compartments) {
          #define the emission, solve and retrieve steady state masses
          emissions <- data.frame(Abbr = c(emission_compartment), Emis = 1/3600/24) #emission of 1kg/d input in kg/s - resulting steady state masses (kg) can be divided by 1 (kg/d) to get FF (d)
          World$NewSolver("SteadyStateSolver")
          World$Solve(emissions = emissions)
          
          Masses <- World$Masses()

          Masses_grouped_over_species <- Masses |>
            left_join(states, by = "Abbr") |>
            group_by(Scale, SubCompart) |>
            summarise(Mass_kg = sum(Mass_kg), .groups = "drop") |>
            filter(!Scale %in% c("Arctic", "Moderate", "Tropic") & SubCompart != "othersoil") |> #Ignore global scale of SBoo
            
            # Combine air + cloudwater separately for Regional and Continental
            mutate(SubCompart = ifelse(Scale %in% c("Regional", "Continental") & SubCompart %in% c("air", "cloudwater"),
                                       "air", SubCompart)) |>
            group_by(Scale, SubCompart) |>
            summarise(Mass_kg = sum(Mass_kg), .groups = "drop") |>
            mutate( #reorder the resulting df
              Scale     = factor(Scale, levels = c("Regional", "Continental")),
              SubCompart = factor(SubCompart, levels = c("air","river","lake","sea","deepocean","freshwatersediment","lakesediment","marinesediment","naturalsoil","agriculturalsoil")) #match the list refined for emission/receiving compartments
            ) |>
            arrange(Scale, SubCompart)|>
            
            mutate(region = reg)|>
            mutate(polymer = pol)|>
            mutate(size = size)|>
            mutate(shape = shape)|>
            mutate(emission_compartment = emission_compartment) |>
            mutate(FF = Mass_kg)|> #Mass is kg is actually the FF (d) due to the emission vector setup
            mutate(volume = volume_compartments) |> 
            mutate(CF_comp_PAF_m3_day = Mass_kg * eef_compartments) |> #Compartmental impacts (PAF.m3.d/kg)
            mutate(CF_comp_PAF_day = CF_comp_PAF_m3_day / volume_compartments) |> #Compartmental impacts (PAF.d/kg)
            
            dplyr::select(-Mass_kg)
          
          ########
          CF_mid_PAF_day <- as.data.frame(t(as.matrix(SDF) %*% as.matrix(Masses_grouped_over_species$CF_comp_PAF_day))) %>%
          mutate(region = reg,
                  polymer = pol,
                  size = size,
                  shape = shape,
                  emission_compartment = emission_compartment,
                  CF_mid_PAF_day = sum(as.data.frame(t(as.matrix(SDF) %*% as.matrix(Masses_grouped_over_species$CF_comp_PAF_day)))))
          
          CF_end_PDF_year <- as.data.frame(t(as.matrix(SDF) %*% as.matrix(Masses_grouped_over_species$CF_comp_PAF_day))*SF/365) %>%
          mutate(region = reg,
                 polymer = pol,
                 size = size,
                 shape = shape,
                 emission_compartment = emission_compartment,
                 CF_end_PDF_year = sum(as.data.frame(t(as.matrix(SDF) %*% as.matrix(Masses_grouped_over_species$CF_comp_PAF_day)))*SF/365))
        
          #ReCiPE: multiply ecosystem level CFs (PDF.yr) by the amount of species in that ecosystem to get species.yr
          CF_end_species_year <- as.data.frame(t(as.matrix(list_tot_species) * as.matrix(SDF) %*% as.matrix(Masses_grouped_over_species$CF_comp_PAF_day))*SF/365) %>%
          mutate(region = reg,
                   polymer = pol,
                   size = size,
                   shape = shape,
                   emission_compartment = emission_compartment,
                   CF_end_species_year = sum(as.data.frame(t(as.matrix(list_tot_species) * as.matrix(SDF) %*% as.matrix(Masses_grouped_over_species$CF_comp_PAF_day))*SF/365)))
          
          
          #in PDF.m2.yr units, superimposed compartments (e.g. water column and sediments) 
          #are added up in PDF, taking into account the compartment in which the species are affected by MPs.
          CF_end_PDF_m2_year <- Masses_grouped_over_species |> 
            mutate(CF_comp_PDF_m2_year = CF_comp_PAF_day * areas_compartments *SF/365) |> 
            mutate(CF_comp_PDF_m2_year = ifelse(Scale %in% c("Regional", "Continental") & SubCompart %in% c("river"),
                                       CF_comp_PDF_m2_year * FracSpe_wc_aqua , CF_comp_PDF_m2_year)) |> 
            mutate(CF_comp_PDF_m2_year = ifelse(Scale %in% c("Regional", "Continental") & SubCompart %in% c("freshwatersediment"),
                                            CF_comp_PDF_m2_year * FracSpe_sed_aqua, CF_comp_PDF_m2_year)) |> 
            
            mutate(CF_comp_PDF_m2_year = ifelse(Scale %in% c("Regional", "Continental") & SubCompart %in% c("lake"),
                                       CF_comp_PDF_m2_year * FracSpe_wc_aqua, CF_comp_PDF_m2_year)) |>
            mutate(CF_comp_PDF_m2_year = ifelse(Scale %in% c("Regional", "Continental") & SubCompart %in% c("lakesediment"),
                                            CF_comp_PDF_m2_year * FracSpe_sed_aqua, CF_comp_PDF_m2_year)) |>
            
            mutate(CF_comp_PDF_m2_year = ifelse(Scale %in% c("Regional", "Continental") & SubCompart %in% c("sea"),
                                       CF_comp_PDF_m2_year * FracSpe_ws_marine, CF_comp_PDF_m2_year)) |>
            mutate(CF_comp_PDF_m2_year = ifelse(Scale %in% c("Regional", "Continental") & SubCompart %in% c("deepocean"),
                                                CF_comp_PDF_m2_year * FracSpe_wc_marine, CF_comp_PDF_m2_year)) |>
            mutate(CF_comp_PDF_m2_year = ifelse(Scale %in% c("Regional", "Continental") & SubCompart %in% c("marinesediment"),
                                            CF_comp_PDF_m2_year * FracSpe_sed_marine, CF_comp_PDF_m2_year)) |>
            
            #Rename superimposed compartments as rw_tot, lw_tot or sw_tot (weighted using the percentage of species that feed in each compartment)
            mutate(SubCompart = ifelse(Scale %in% c("Regional", "Continental") & SubCompart %in% c("river", "freshwatersediment"),
                                     "rw_tot", as.character(SubCompart))) |> 
            mutate(SubCompart = ifelse(Scale %in% c("Regional", "Continental") & SubCompart %in% c("lake", "lakesediment"),
                                       "lw_tot", as.character(SubCompart))) |>
            mutate(SubCompart = ifelse(Scale %in% c("Regional", "Continental") & SubCompart %in% c("sea", "deepocean", "marinesediment"),
                                       "sw_tot", as.character(SubCompart))) |>
            group_by(Scale, SubCompart) |>
            summarise(CF_end_PDF_m2_year = sum(CF_comp_PDF_m2_year), .groups = "drop") |>
            
            #Combine impacts by ecosystem (fw, marine and terrestrial)
            mutate(Marine_Ecosystem = ifelse(Scale %in% c("Regional", "Continental") & SubCompart %in% c("sw_tot"),
                                             CF_end_PDF_m2_year, 0)) |> 
            mutate(Freshwater_Ecosystem = ifelse(Scale %in% c("Regional", "Continental") & SubCompart %in% c("rw_tot","lw_tot"),
                                             CF_end_PDF_m2_year, 0)) |> 
            mutate(Terrestrial_Ecosystem = ifelse(Scale %in% c("Regional", "Continental") & SubCompart %in% c("naturalsoil","agriculturalsoil"),
                                                 CF_end_PDF_m2_year, 0)) |> 
            summarise(across(where(is.numeric), sum, na.rm = TRUE)) |>
            
            #dplyr::select(-as.character(Scale)) |>
            mutate(region = reg,
                 polymer = pol,
                 size = size,
                 shape = shape,
                 emission_compartment = emission_compartment)
      
          #Append all FF, midpoint and endpoints CFs results
          results_FF <- bind_rows(results_FF,Masses_grouped_over_species) #Saving FFs for each emission/receiving comp
          results_CF_mid_PAF_day <- bind_rows(results_CF_mid_PAF_day,CF_mid_PAF_day) #One row added for a region, polymer, size, shape, with all CFs (midpoint, endpoint, etc)
          results_CF_end_PDF_year <- bind_rows(results_CF_end_PDF_year,CF_end_PDF_year) #One row added for a region, polymer, size, shape, with all CFs (midpoint, endpoint, etc)
          results_CF_end_species_year <- bind_rows(results_CF_end_species_year,CF_end_species_year) #One row added for a region, polymer, size, shape, with all CFs (midpoint, endpoint, etc)
          results_CF_end_PDF_m2_year <- bind_rows(results_CF_end_PDF_m2_year,CF_end_PDF_m2_year) #One row added for a region, polymer, size, shape, with all CFs (midpoint, endpoint, etc)
          
          count <- count + 1
          setTxtProgressBar(pb, count)
          }
      }
    }
  }
}
close(pb)

# Load workbook if it exists, otherwise create a new one
wb <- if (file.exists("vignettes/CaseData/FateFactorsUpdate/results_FF_CF.xlsx")) {
  loadWorkbook("vignettes/CaseData/FateFactorsUpdate/results_FF_CF.xlsx")
} else {
  createWorkbook()
}

# Replace or add each results sheet
writeData(wb, sheet = "results_FF", results_FF, withFilter = FALSE)
writeData(wb, sheet = "results_CF_mid_PAF_day", results_CF_mid_PAF_day, withFilter = FALSE)
writeData(wb, sheet = "results_CF_end_PDF_year", results_CF_end_PDF_year, withFilter = FALSE)
writeData(wb, sheet = "results_CF_end_species_year", results_CF_end_species_year, withFilter = FALSE)
writeData(wb, sheet = "results_CF_end_PDF_m2_year", results_CF_end_PDF_m2_year, withFilter = FALSE)

# Save without deleting other sheets
saveWorkbook(wb, "vignettes/CaseData/FateFactorsUpdate/results_FF_CF.xlsx", overwrite = TRUE)


###

wb <- if (file.exists("vignettes/CaseData/FateFactorsUpdate/kvalues.xlsx")) {
  loadWorkbook("vignettes/CaseData/FateFactorsUpdate/kvalues.xlsx")
} else {
  createWorkbook()
}

# Replace or add each results sheet
writeData(wb, sheet = "kvalues2", k_detailed, withFilter = FALSE)

# Save without deleting other sheets
saveWorkbook(wb, "vignettes/CaseData/FateFactorsUpdate/kvalues.xlsx", overwrite = TRUE)

#write.xlsx(results_FF, file = "results_FF.xlsx")
#write.xlsx(results_CF, file = "results_CF.xlsx")

# remove_advection <- data.frame(varName = "x_Advection_Air", 
#                                fromScale = "Continental",
#                                toScale = "Moderate",
#                                fromSubCompart = "air",
#                                toSubCompart = "air",
#                                Waarde = 0)
# 
# World$mutateVars(remove_advection)
# 
# World$fetchData("x_Advection_Air")
# 
# World$UpdateDirty(unique(remove_advection$varName))
# 

