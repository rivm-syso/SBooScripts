source("baseScripts/initWorld_onlyParticulate.R")

data <- read.csv("/rivm/n/rijkdv/testing_simplebox/SBData.csv")


World$ScaleSheet
World$SetConst (Scale = " Arctic", FRACsea = 0.6 )
World$fetchData("FRACsea")
World$SetConst(FRACsea = 0.5)

ClassicStateModule <- ClassicNanoWorld$new("data", substance)
ClassicStateModule$Defs
#with this data we create an instance of the central "core" object,
World <- SBcore$new(ClassicStateModule)