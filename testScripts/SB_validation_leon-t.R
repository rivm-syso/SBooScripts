# SimpleBox OO validation using the PROMISCES datasets

# Load all required packages
library(readr)
library(dplyr)
library(ggdag)
library(rlang)
library(foreach)
library(iterators)
library(openxlsx)

# Initialize the World object



# inoutname <- paste0("/rivm/n/defaresj/Documents/LEON-T input output.xlsx")

# SystemIn <- read.xlsx(inoutname,
#                       sheet=2,
#                       colNames=TRUE,
#                       rows=c(1:9),
#                       cols = c(1:3))
# LandscapeIn <- read.xlsx(inoutname,
#                          sheet = 1,
#                          colNames = TRUE,
#                          rows = c(1:27),
#                          cols = c(1:5))
# SubstanceIn <- read.xlsx(inoutname,
#                          sheet = 2,
#                          colNames = TRUE,
#                          rows = c(16:28),
#                          cols = c(1:20))
# EmissionIn <- read.xlsx(inoutname,
#                         sheet = 4,
#                         colNames = TRUE,
#                         rows = c(1:3),
#                         cols = c(1:2))
# Out <- c(t(read.xlsx(inoutname,
#                      sheet = 4,
#                      colNames = FALSE,
#                      rows = 1)))


# Initialize the World object


# Choose the substance to model.
Substance <- "microplastic"

source("baseScripts/initWorld_onlyParticulate.R")

World$substance <- Substance

World$NewSolver("SB1Solve")

indexS <- which(colnames(EmissionIn) == Substance)
#emissions <- data.frame(Abbr = EmissionIn$Abrr, Emis = EmissionIn[,indexS])
emissions <- data.frame(Abbr = c("w1RS", "s3RS"), Emis = c(1000, 1000))

# Convert emission to [g/s]
MW <- World$fetchData("MW")
emissions <- emissions |> mutate(Emis = Emis/(365*24*60*60))





# Update the transfer rates based on the newly set and calculated parameters
World$UpdateKaas()



masses <- filter(World$Solve(emissions), Scale == "Regional") %>% arrange(SubCompart)   
masses <- as_tibble(masses)

# Convert mass output to Kg
#masses <- masses |> mutate(EqMass = EqMass*MW)

print(masses)                          

# Get the concentrations for the compartments
Concentrations <- filter(World$GetConcentration(), Scale == "Regional")    
Concentrations <- Concentrations[,-c(1,2)]


Conc_Out <- data.frame(
  Concentration = rep("-", 4)
)

# Gas and Aerosol/Clouds in Air
Cair <- Concentrations$Concentration[which(Concentrations$SubCompart == "air")]
FRgas <- World$fetchData("FRingas")$FRingas[which(World$fetchData("FRingas")$Scale == "Regional")]
Concentrations <- rbind.data.frame(Concentrations, c("air - gas", Cair * FRgas, "g/m^3"))

Conc_Out$Concentration[1] <- Cair * FRgas


# Dissolved and Suspended in Freshwater
Criver <- as.numeric(Concentrations$Concentration[which(Concentrations$SubCompart == "river")])
FRw1 <- World$fetchData("FRinw")$FRinw[which(World$fetchData("FRinw")$Scale == "Regional" & World$fetchData("FRinw")$SubCompart == "river")]
Concentrations$Concentration[which(Concentrations$SubCompart == "river")] <- Criver / 1000
Concentrations <- rbind(Concentrations, c("river - dissolved", Criver / 1000 * FRw1, "g/L"))

Conc_Out$Concentration[2] <- Criver / 1000 * FRw1


# Water and Solid in Freshwater Sediment
Csediment <- as.numeric(Concentrations$Concentration[which(Concentrations$SubCompart == "freshwatersediment")])
FRwinsd <- World$fetchData("FRACw")$FRACw[which(World$fetchData("FRACw")$Scale == "Regional" & World$fetchData("FRACw")$SubCompart == "freshwatersediment")]
KPsuspsd1 <- World$fetchData("Kp")$Kp[which(World$fetchData("Kp")$SubCompart == "freshwatersediment")]
FRsinsd <- World$fetchData("FRACs")$FRACs[which(World$fetchData("FRACs")$Scale == "Regional" & World$fetchData("FRACs")$SubCompart == "freshwatersediment")]
RhoS <- World$fetchData("RhoCP")$RhoCP[which(World$fetchData("RhoCP")$SubCompart == "freshwatersediment")]
Concentrations <- rbind(Concentrations, c("freshwatersediment - solid", Csediment*FRsinsd/(FRwinsd/(KPsuspsd1*RhoS/1000)+FRsinsd)*(1000)/(FRsinsd*RhoS), "g/kg d"))

Conc_Out$Concentration[3] <-  Csediment*FRsinsd/(FRwinsd/(KPsuspsd1*RhoS/1000)+FRsinsd)*(1000)/(FRsinsd*RhoS)


# Water and Solid in Other Soil
Cothersoil <- as.numeric(Concentrations$Concentration[which(Concentrations$SubCompart == "othersoil")])
FRsins3 <- World$fetchData("FRACs")$FRACs[which(World$fetchData("FRACs")$Scale == "Regional" & World$fetchData("FRACs")$SubCompart == "othersoil")]
Concentrations <- rbind(Concentrations, c("othersoil - solid", Cothersoil*0.999*(1000)/(FRsins3*RhoS), "g/kg d"))

Conc_Out$Concentration[4] <- Cothersoil*0.999*(1000)/(FRsins3*RhoS)


Conc_Out$Concentration <- as.numeric(Conc_Out$Concentration)


# wb <- loadWorkbook(inoutname)
# startCol <- (which(Out == Substance)-1)*2 + 1
# writeData(wb,
#           sheet = "Output",
#           x = Conc_Out,
#           startCol = startCol,
#           startRow = 3,
#           colNames = FALSE)

#inoutnameT <- "/rivm/n/defaresj/Documents/Bakker (2003) in SimpleBox 4/Bakker (2003) input output T.xlsx"

# saveWorkbook(wb,inoutname,overwrite = T)

print(Conc_Out)




