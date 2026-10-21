# Test Building States based on The3D "sheets" == primary dataframe for a dimension
devtools::load_all("../SBoo/")

SBooDataLocation = "../SBooScripts/data"

SB <- sboo::SBcore$new(SBooDataLocation, SuBmode = "substance_data_nano.json", debugR = T)

#debugonce(KswDorC)
#SB$fetchData("KswDorC")

#debugonce(KdegDorC)
#SB$fetchData("KdegDorC")

#debugonce(k_Degradation )
#SB$fetchData("k_Degradation")

#debugonce(k_Desorption)
#SB$fetchData("k_Desorption")

#debugonce(k_Erosion)
#SB$fetchData("k_Erosion")

#debugonce(k_Erosion)
#SB$fetchData("k_Erosion")

#debugonce(k_Escape)
#SB$fetchData("k_Escape")
 
#debugonce(k_HeteroAgglomeration.a)
#SB$fetchData("k_HeteroAgglomeration.a")

#debugonce(k_HeteroAgglomeration.a)
#SB$fetchData("k_HeteroAgglomeration.a")

#debugonce(k_HeteroAgglomeration.wsd)
#SB$fetchData("k_HeteroAgglomeration.wsd")

#debugonce(k_Leaching)
#SB$fetchData("k_Leaching")

#debugonce(k_Resuspension)
#SB$fetchData("k_Resuspension")

#debugonce(k_Runoff)
#SB$fetchData("k_Runoff")

#debugonce(k_Sedimentation)
#SB$fetchData("k_Sedimentation")

#debugonce(k_WetDeposition)
#SB$fetchData("k_WetDeposition")

#debugonce(k_Fragmentation)
#SB$fetchData("k_Fragmentation")

# SB$fetchData("kdeag")

#debugonce(k_Deagglomeration)
#SB$fetchData("k_Deagglomeration")

SB$UpdateKaas()
