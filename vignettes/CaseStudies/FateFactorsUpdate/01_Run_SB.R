library(tidyverse)
library(openxlsx)
setwd("~/Documents/GitHub/SBooScripts")
# Read csvs
plastic_values <- read.xlsx("vignettes/CaseData/FateFactorsUpdate/SI_3_Fate.xlsx", sheet = "Polymer_list") 

regions <- read.xlsx("vignettes/CaseData/FateFactorsUpdate/SI_3_Fate.xlsx", sheet = "4.1.Regio_param") 

colnames(regions) <- regions[2,]

sizes <- c(1,10,100,1000,5000) #D be divided by 2
shapes <- c("Sphere","Fiber","Film")
#list of possible emission compartments to loop over
#only SOLID
emission_compartments <- c("aRS","w1RS","w0RS","w2RS","sd1RS","sd0RS","sd2RS","s1RS","s2RS",
                           "aCS","w1CS","w0CS","w2CS","sd1CS","sd0CS","sd2CS","s1CS","s2CS") 

regions_rows = nrow(regions)
#Import the data with regionalization. SOme variables are left as the default input of SBoo
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

#Change the drag method to Dioguardi 2018
DragMethod_df <- data.frame(varName = "DragMethod",
                       Waarde = "Bagheri")
World$mutateVars(DragMethod_df)
World$UpdateDirty(unique(DragMethod_df$varName))

global_df <- data.frame(varName = c("VertDistance", "VertDistance", "VertDistance", "VertDistance", "VertDistance"), 
                        SubCompart = c("freshwatersediment","lakesediment","marinesediment","naturalsoil","agriculturalsoil"),
                        #Scale = c("Continental","Regional"),
                        Waarde = c(0.1, 0.1, 0.1, 0.1, 0.1)) #Set the depth of all sediments and soil to 10cm, as per USEtox

World$mutateVars(global_df)
World$UpdateDirty(unique(global_df$varName))

# Loop over regions
region_names <- colnames(regions)[4:11]
polymer_names <- colnames(plastic_values)[3:ncol(plastic_values)]

# Instead of this, make a dataframe per emission compartment - emission scale combination
#emissions <- data.frame(Abbr = c("aRS", "s2RS", "w1RS"), Emis = c(10, 10, 10)) 


# Get the names and abbreviations of all compartments
states <- World$states$asDataFrame
count <- 0
results <- data.frame(region = character(),
                      polymer = character(),
                      size = integer(),
                      shape = character(),
                      emission_compartment = character(),
                      Scale = character(),
                      SubCompart = character(),
                      FF = numeric())


#####TEST
#Variables to test
reg = "North America"
pol = "PET"
size = 1000
shape = "Sphere"


# #emission_compartment = "sd0RS" emissions into regional lakesediments
# emission_compartment = "w2RS" #emissions into regional lakewater
# ##
# region_df <- regions[, c("varName", "Scale", "SubCompart", reg)] 
# names(region_df)[ncol(region_df)] <- "Waarde"
# 
# region_df <- region_df |>
#   mutate(Waarde = as.numeric(Waarde))
# 
# World$mutateVars(region_df)
# World$UpdateDirty(unique(region_df$varName))
# #### Polymer loop
#   #Import the properties of that polymer from the df
#   print(pol)
#   polymer_df <- plastic_values[1:13,c("varName","SubCompart",pol)]
#   names(polymer_df)[ncol(polymer_df)] <- "Waarde" #rename the last column "Waarde" instead of name of pol
#   #browser()
#   
#   polymer_df <- polymer_df |>
#     mutate(Waarde=as.numeric(Waarde))
#   
#   #Set the new values for RhoS, Kssdr, CorFacSSA and MinSettVel for the specific polymer
#   World$mutateVars(polymer_df)
#   World$UpdateDirty(unique(polymer_df$varName))
#   
#   
#   ######loop over size    
#   #for (size in sizes) {
#     variable_df <- data.frame(varName = "RadS",
#                               Waarde = size/2*1000) #convert D to R and convert um to nm (SBoo takes RadS as nm)
#     
#     World$mutateVars(variable_df)
#     World$UpdateDirty(unique(variable_df$varName))
#     
#     
#     ####Loop over shape
#     #for (shape in shapes) {
#       shape_df <- data.frame(varName = "Shape",
#                              Waarde = shape)
#       World$mutateVars(shape_df)
#       World$UpdateDirty(unique(shape_df$varName))
#       
#       
#       #####loop over emission compartments
#       #for (emission_compartment in emission_compartments) {
#         #define the emission
#         emissions <- data.frame(Abbr = c(emission_compartment), Emis = 1/3600/24) #emission of 1kg/d in kg/s
#         World$NewSolver("SteadyStateSolver")
#         World$Solve(emissions = emissions)
#         
#         #k_matrix = World$exportEngineR()
#         #k_dataframe = World$kaas
#         
#         
#         Masses <- World$Masses()
#         
#         Masses_grouped_over_species <- Masses |>
#           left_join(states, by = "Abbr") |>
#           group_by(Scale, SubCompart) |>
#           summarise(Mass_kg = sum(Mass_kg), .groups = "drop") |>
#           filter(!Scale %in% c("Arctic", "Moderate", "Tropic") & SubCompart != "othersoil") |> #Ignore global scale of SBoo
#           
#           # Combine air + cloudwater separately for Regional and Continental
#           mutate(SubCompart = ifelse(Scale %in% c("Regional", "Continental") & SubCompart %in% c("air", "cloudwater"),
#                                      "air", SubCompart)) |>
#           group_by(Scale, SubCompart) |>
#           summarise(Mass_kg = sum(Mass_kg), .groups = "drop") |>
#           
#           mutate(emission_compartment = emission_compartment) |>
#           mutate(region = reg)|>
#           mutate(polymer = pol)|>
#           mutate(size = size)|>
#           mutate(shape = shape)|>
#           mutate(FF = Mass_kg)|>
#           dplyr::select(-Mass_kg)
#         #mutate(receiving_compartment = SubCompart)
#         #count <- count+1
#         #print(count)
#         
#         
#         #Use the empty one I want to fill
#         #make a mini empty df
#         #bind_rows( give 2 df1-the emopty row,df2 ) 
#         #append=bind row
#         results <- bind_rows(results,Masses_grouped_over_species) 
#         
#  
#         #World$moduleList[["x_LakeOutflow"]]$execute(debugAt=list())
#         
#         
############




for(reg in region_names){
  region_df <- regions[, c("varName", "Scale", "SubCompart", reg)]
  names(region_df)[ncol(region_df)] <- "Waarde"

  region_df <- region_df |>
    mutate(Waarde = as.numeric(Waarde))

  World$mutateVars(region_df)
  #World$UpdateDirty(unique(region_df$varName))
  vars_to_update <- unique(region_df$varName) 

  # Polymer loop
  for(pol in polymer_names){
    #Import the properties of that polymer from the df
    print(pol)
    polymer_df <- plastic_values[1:13,c("varName","SubCompart",pol)]
    names(polymer_df)[ncol(polymer_df)] <- "Waarde" #rename the last column "Waarde" instead of name of pol
    #browser()
    
    polymer_df <- polymer_df |>
      mutate(Waarde=as.numeric(Waarde))
    
    #Set the new values for RhoS, Kssdr, CorFacSSA and MinSettVel for the specific polymer
    World$mutateVars(polymer_df)
    #World$UpdateDirty(unique(polymer_df$varName))
    vars_to_update <- c(vars_to_update,unique(polymer_df$varName))



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
        
  
        #loop over emission compartments
        for (emission_compartment in emission_compartments) {
          #define the emission
          emissions <- data.frame(Abbr = c(emission_compartment), Emis = 1/3600/24) #emission of 1kg/d in kg/s
          World$NewSolver("SteadyStateSolver")
          World$Solve(emissions = emissions)

          k_matrix = World$exportEngineR()

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
            mutate(region = reg)|>
            mutate(polymer = pol)|>
            mutate(size = size)|>
            mutate(shape = shape)|>
            mutate(FF = Mass_kg)|>
            mutate(emission_compartment = emission_compartment) |>
            dplyr::select(-Mass_kg)
            
          results <- bind_rows(results,Masses_grouped_over_species)
        }
      }
    }
  }
}

write.xlsx(results, file = "results_FF.xlsx")

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

