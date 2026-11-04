# Test Building States based on The3D "sheets" == primary dataframe for a dimension
devtools::load_all("../SBoo/")

SBooDataLocation = "data"

SB <- sboo::SBcore$new(SBooDataLocation, SuBmode = "substance_data_nano.json", debugR = T)

SB$UpdateKaas()
