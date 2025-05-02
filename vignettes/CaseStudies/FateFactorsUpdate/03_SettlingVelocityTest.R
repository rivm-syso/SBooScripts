library(tidyverse)
library(openxlsx)

setwd("~/Documents/GitHub/SBooScripts")
# Read csvs
plastic_values <- read.xlsx("vignettes/CaseData/FateFactorsUpdate/SI_3_Fate.xlsx", sheet = "Polymer_list") 

regions <- read.xlsx("vignettes/CaseData/FateFactorsUpdate/SI_3_Fate.xlsx", sheet = "4.1.Regio_param") 

colnames(regions) <- regions[2,]

sizes <- c(1,10,100,1000,5000) #To be divided by 2
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
  select(Variable, Scale, SubCompart, `North America`, `Latin America`, Europe, 
         `Africa & Middle East`, `Central Asia`, `Southeast Asia`, `Northern regions`, `Oceania`) |>
  rename(varName = Variable)


# Initalize World
source("baseScripts/initWorld_onlyPlastics.R")
#World$moduleList[["x_LakeOutflow"]]$execute(debugAt=list())

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

# Get the names and abbreviations of all compartments
states <- World$states$asDataFrame
count <- 0
results <- data.frame(polymer = character(),
                      size = integer(),
                      shape = character(),
                      velocity = integer(),
                      velocity_air = integer(),
                      density = integer()
                      )





#Use the empty one I want to fill
#make a mini empty df
#bind_rows( give 2 df1-the emopty row,df2 ) 
#append=bind row
#results <- bind_rows(results,Masses_grouped_over_species) 


#World$moduleList[["x_LakeOutflow"]]$execute(debugAt=list())


############




reg = "North America"
  region_df <- regions[, c("varName", "Scale", "SubCompart", reg)]
  names(region_df)[ncol(region_df)] <- "Waarde"

  region_df <- region_df |>
    mutate(Waarde = as.numeric(Waarde))
  #print("test1")
  World$mutateVars(region_df)
  World$UpdateDirty(unique(region_df$varName))

  
  # Polymer loop
  for(pol in polymer_names){
    #Import the properties of that polymer from the df
    print(pol)
    polymer_df <- plastic_values[1:13,c("varName","SubCompart",pol)]
    names(polymer_df)[ncol(polymer_df)] <- "Waarde" #rename the last column "Waarde" instead of name of pol
    polymer_df <- polymer_df |>
      mutate(Waarde=as.numeric(Waarde))
    #Set the new values for RhoS, Kssdr, CorFacSSA and MinSettVel for the specific polymer
    World$mutateVars(polymer_df)
    World$UpdateDirty(unique(polymer_df$varName))



    #loop over size
    for (size in sizes) {
      variable_df <- data.frame(varName = "RadS",
                                Waarde = size/2*1000) #convert D to R and convert um to nm (SBoo takes RadS as nm)
      #print("test5")
      World$mutateVars(variable_df)
      World$UpdateDirty(unique(variable_df$varName))


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
        size_df <- data.frame(
          varName = c("Shortest_side", "Intermediate_side", "Longest_side"),
          Waarde = c(Shortest_side, Intermediate_side, Longest_side)
        )
        World$mutateVars(shape_df)
        World$mutateVars(size_df)
        World$UpdateDirty(unique(c(shape_df$varName, size_df$varName)))
        
        # Fetch the velocity data for one comp
        data <- World$fetchData("SettlingVelocity")
        selected_row <- subset(data, Scale == "Continental" & SubCompart == "sea" & Species == "Large")
        selected_value <- selected_row$SettlingVelocity
        
        #air velocity
        selected_row2 <- subset(data, Scale == "Continental" & SubCompart == "air" & Species == "Large")
        selected_value2 <- selected_row2$SettlingVelocity
        
        #density
        data2 <- World$fetchData("rho_species")
        selected_row3 <- subset(data2, Scale == "Continental" & SubCompart == "sea" & Species == "Large")
        selected_value3 <- selected_row3$rho_species
        
        Settling_Velocities <- tibble(
          polymer = pol,
          size = size,
          shape = shape,
          velocity = selected_value,
          velocity_air = selected_value2,
          density = selected_value3
        )

          results <- bind_rows(results,Settling_Velocities)
        }
      }
    }

if (DragMethod_df$Waarde == "Original") {
  write.xlsx(results, file = "results2.xlsx")
} else {
  write.xlsx(results, file = "results.xlsx")
}






