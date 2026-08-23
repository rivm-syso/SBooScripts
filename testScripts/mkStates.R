# Test Building States based on The3D "sheets" == primary dataframe for a dimension
devtools::load_all("../SBoo/")

SBooDataLocation = "data"
SBmode = "Molecular"

SB <- sboo::SBcore$new(SBooDataLocation, SuBmode = "data/substance_data.json", debugR = T)

SB$fetchData("MTC_2sd")
debugonce(FRorig_spw)
SB$fetchData("FRorig_spw")
