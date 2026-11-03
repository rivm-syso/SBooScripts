# Test Building States based on The3D "sheets" == primary dataframe for a dimension
devtools::load_all("../SBoo/")


SBooDataLocation = "data"
SBmode = "Molecular"
# SBmode = "Particulate"

Defs = c(
  "ScaleSubCompartData",
  "ScaleSpeciesData",
  "SubCompartSpeciesData",
  "ScaleSheet",
  "SubCompartSheet",
  "SpeciesSheet",
  "ScaleProcesses",
  "SubCompartProcesses",
  "SpeciesProcesses",
  "Compartments",
  "Substances",
  "SpeciesCompartments",
  "SubstanceCompartments",
  "SubstanceSubCompartSpeciesData",
  "CONSTANTS",
  "MatrixSheet",
  "FlowIO",
  "QSARtable",
  "SomeFromTo",
  "Units"
)

# SB <- sboo::SBcore$new(SBooDataLocation, SuBmode = "substance_data_mp.json", debugR = T)
SB <- sboo::SBcore$new(SBooDataLocation, SuBmode = "substance_data.json", debugR = T)
# SB <- sboo::SBcore$new(SBooDataLocation, SuBmode = "substance_data_nano.json", debugR = T)

SB$UpdateKaas()
# Testje met solven
emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), Emis = c(10000, 10000, 10000)) 
emissions <- emissions |>
  mutate(Emis = Emis*1000/(365*24*60*60)) 
SB$NewSolver("SteadyStateSolver")
SB$Solve(emissions = emissions)


# Tjebbe development plek 

# Initworld bevat nog wat constants die met SetConst worden ingevoerd obv Molecular of Particulate,
# In dit geval gewoon als stofeigenschap in de JSON

#debugonce(MTC_2sd)
SB$fetchData("MTC_2sd") # Klaar match
# Niet voor nm

#debugonce(FRorig_spw)
SB$fetchData("FRorig_spw") # Klaar match
# Match voor nm

# #debugonce(MTC_2w)
SB$fetchData("MTC_2w") #Klaar match
# Niet voor nm

# #debugonce(MTC_2s)
SB$fetchData("MTC_2s") #klaar match
# Niet voor nm

#debugonce(FRorig)
SB$fetchData("FRorig") #klaar match
# Match voor nm

#debugonce(Kacompw)
SB$fetchData("Kacompw") #klaar match na conversie si
# Match voor nm

# #debugonce(AreaLand)
SB$fetchData("AreaLand") #Klaar match
# Match voor nm

# #debugonce(AreaSea)
SB$fetchData("AreaSea") #Klaar match
# Match voor nm

#debugonce(Tempfactor)
SB$fetchData("Tempfactor") #klaar met scaffolding, heeft in development meerdere waardes voor Species Unbound
# Veel minder rijen dan dev, in dev hebbe globale schalen wel nog alles 

# #debugonce(Kaers)
SB$fetchData("Kaers") #Klaar match
#  heeft wel goede check nodig. Heeft in Corg extra matrices (porewater en aerosol = NA), met left_join, verder klaar


#debugonce(FracROWatComp)
SB$fetchData("FracROWatComp") #Klaar matcht met dev
# Match met nm

#debugonce(FRACs)
SB$fetchData("FRACs") #Klaar match


# #debugonce(FRACw)
SB$fetchData("FRACw") #Klaar match

# #debugonce(FRACa)
SB$fetchData("FRACa") #Klaar 
#matcht niet, in development hebben globale schalen freshwater&Lake sediment compartimenten, deze bestaan niet.Waar gaat het fout
# FRAC funcs hebben Species als sleutel ook al maakt het geen verschil, clip states vvereist dit.

debugonce(KocDorC)
SB$fetchData("KocDorC") #klaar match


#debugonce(KocAltDorC)
SB$fetchData("KocAltDorC")  #klaar match

#debugonce(Area)
SB$fetchData("Area") #klaar match

#Paar dingetjes over v_Area.R
#1 in globale schalen heeft volgens de oude logica freshwater/lake sediment geen area omdat deze bepaald wordt door 
#de area van de river/lake compartimenten. Deze compartimenten zitten niet in deze schalen toch? Zorgt dat voor problemen
#Als er geen area is?
#2 Volgens de oude logica hebben globale schalen met bodem = naturalsoil het gehele landoppervlakte. Echter zie ik in de input data
#dat de globale schalen enkel othersoil hebben ipv natural soil -> aangepast in staterules
#zelf area clwt erbij gezet na filter states. 

#debugonce(Kaerw)
SB$fetchData("Kaerw") #Klaar match
# In nm geeft dataframe met kolommen maar zonder rijen terug, in dev is dit NA

# #debugonce(KswDorC)
SB$fetchData("KswDorC") #Klaar match

# #debugonce(Ksw.alt)
SB$fetchData("Ksw.alt") #Klaar match
# Match met nm

# #debugonce(D)
SB$fetchData("D") # klaar match
# match met nm

#debugonce(Volume)
SB$fetchData("Volume") #Klaar, match behalve voor cloudwater (niet voor Unbound)
# match met nm

# #debugonce(FRinaerw)
SB$fetchData("FRinaerw") #klaar match
# niet beschikbaar in nm                             

# #debugonce(FRinaers)
SB$fetchData("FRinaers") # klaar match
# niet beschikbaar in nm

# #debugonce(RunoffFlow)
SB$fetchData("RunoffFlow") #klaar match
# match met nm

# #debugonce(RainOnFreshwater)
SB$fetchData("RainOnFreshwater") #klaar match
# match met nm

#debugonce(Kp)
SB$fetchData("Kp") #klaar match
# match maar lege df ipv NA

# #debugonce(KpCOL)
SB$fetchData("KpCOL") #Klaar match
# Match met nm

# #debugonce(FRinw)
SB$fetchData("FRinw") #Klaar match, mist alleen river in globaal. StateRules bepalen dit, zit er River in globaal
# match met nm maar lege df ipv NA

#debugonce(Kscompw)
SB$fetchData("Kscompw") #klaar match
# match met nm maar lege df ipv NA

# #debugonce(Ksdcompw)
SB$fetchData("Ksdcompw") #klaar match
# niet beschikbaar in nm

# #debugonce(AirFlow)
SB$fetchData("AirFlow") #klaar match
# met met nm

#debugonce(FRingas)
SB$fetchData("FRingas") 
# Lege df ipv NA in dev nm


#debugonce(rad_species) #Alleen voor microplastic match met dev
SB$fetchData("rad_species")

#debugonce(FRins) # Hier kom ik via molecular en particulate niet in
SB$fetchData("FRins")

#debugonce(IntrcptFrac) # Match met dev
SB$fetchData("IntrcptFrac")

#debugonce(MasConc_Otherparticle) # Niet voor mp, molec, of particulate?
SB$fetchData("MasConc_Otherparticle")

#debugonce(Mass2Conc)
SB$fetchData("Mass2Conc") #Deze en die hierbovenw werken niet

#debugonce(MTC_2a)
SB$fetchData("MTC_2a") # deze gebruikt de calculated Kdeg functie die weer shortest side nodig heeft 
# WERKT wel in dev

#debugonce(OtherkAir) #niet voor nu
SB$fetchData("OtherkAir")

#debugonce(rho_species)
SB$fetchData("rho_species") # Match met dev

#debugonce(SettlingVelocity)
SB$fetchData("SettlingVelocity") #Match met dev
# v_SetVelSolve aangepast om vectoren te accepteren en waardes te berekenen
# vervolgens ook f_DragMethod iets aangepast om niet te crashen als er een NA als dragmethod binnen komt. Nadeel van vector werken. hij evalueert de functie ook al heeft de data niet de input die als voorwaarde geldt waardoor de f_drag wordt aangeroepen


debugonce(KdegDorC)
SB$fetchData("KdegDorC") # Match met dev (development heeft wel cloudwater in unbound, staterules verbied dit. Ook geeft dev voor molecular alle species terug?)
#is alleen voor molecular Mat

# 
# #debugonce(rho_species)
# SB$fetchData("rho_species")


# F - Scripts, deze functies zijn ondersteunend en accepteren veel al al vectoren als input
# #debugonce(f_Grav)
# SB$fetchData("f_Grav")
# 
# #debugonce(f_PerimeterParticle)
# SB$fetchData("f_PerimeterParticle")


# FLOWS
# Ik maak nu een dplyr workflow met de gegevein input, later left_join ik de berekende waardes of de scaffolding
# species toevoegen als sleutel

#debugonce(x_ContRiver2Reg)
SB$fetchData("x_ContRiver2Reg")  #Match op 0 want discharge frac is 0
# SB$FromDataAndTo("x_ContRiver2Reg")

# #debugonce(x_RiverDischarge)
SB$fetchData("x_RiverDischarge") #Match


# #debugonce(x_ContSea2Reg)
SB$fetchData("x_ContSea2Reg")  #match

# #debugonce(x_FromModerate2ArctWater)
SB$fetchData("x_FromModerate2ArctWater") #match 


#debug(x_RegSea2Cont)
SB$fetchData("x_RegSea2Cont") #match


# #debugonce(x_FromModerate2ContWater) #Match, hier voor het eerst denk de to. en from. logisch op elkaar gejoined kan dit ook met hierboven
SB$fetchData("x_FromModerate2ContWater")

# #debugonce(x_FromModerate2TropWater) 
SB$fetchData("x_FromModerate2TropWater") #match

# #debugonce(x_LakeOut)
SB$fetchData("x_LakeOut") #Match 

#debugonce(x_OceanMixing2Deep)
SB$fetchData("x_OceanMixing2Deep") #Match 

#debugonce(x_OceanMixing2Sea)
SB$fetchData("x_OceanMixing2Sea") #Match berekent hetzelfde als hierboven maar from and to staan omgewisseld

#debugonce(x_RegSea2Cont)
SB$fetchData("x_RegSea2Cont")  #Match

#debugonce(x_ToModerateWater)
SB$fetchData("x_ToModerateWater") #match


# Voor nano materie
# vignettes/development/quality control/particulate verification.Rmd
# Wat opmerkingkies over nano/particulate deze bij jaap neergelegd 
# Nu verder met K_{functies} voor molecular

#debugonce(k_Adsorption) 
SB$fetchData("k_Adsorption") #klaar

#debugonce(k_Burial)
SB$fetchData("k_Burial") #Kan niet nagaan of dit klopt, bestaat niet in fetchdata in development

#debugonce(k_CWscavenging)
SB$fetchData("k_CWscavenging") #Hier kom ik niet in

#debugonce(k_Deagglomeration)
SB$fetchData("k_Deagglomeration") #Dependancy op kdeag, voor MP, niet beschikbaar in dev

#debugonce(k_Degradation)
SB$fetchData("k_Degradation") #doet wat maar kan ik niet checken, in Dev NA

# #debugonce(Shortest_side)
# SB$fetchData("Shortest_side") 

#debugonce(k_Desorption)
SB$fetchData("k_Desorption") #Doet wat maar in dev NA


#debugonce(k_DryDeposition)
SB$fetchData("k_DryDeposition") #Hier kom ik niet in

#debugonce(k_Erosion)
SB$fetchData("k_Erosion") #Doet het maar niet in DEV (NA)

#debugonce(k_Escape)
SB$fetchData("k_Escape")  #Doet het maar niet in DEV (NA)

#debugonce(kfrag)
SB$fetchData("kfrag") #Unknown dependancy kfrag

#debugonce(k_Fragmentation)
SB$fetchData("k_Fragmentation") #Klaar functie deed niets anders dan combinaties scale/subcompart een NA voor kfrag te geven, else =kfrag


#debugonce(k_HeteroAgglomeration.a)
SB$fetchData("k_HeteroAgglomeration.a")

#debugonce(k_HeteroAgglomeration.wsd)
SB$fetchData("k_HeteroAgglomeration.wsd")

#debugonce(k_Deposition) # NOg even mee wachten
SB$fetchData("k_Deposition")

#debugonce(k_Leaching)
SB$fetchData("k_Leaching")

#debugonce(k_Resuspension)
SB$fetchData("k_Resuspension")

#debugonce(k_Runoff)
SB$fetchData("k_Runoff")

#debugonce(k_Advection)
SB$fetchData("k_Advection")

debugonce(k_Sedimentation)
SB$fetchData("k_Sedimentation")

#debugonce(k_Volatilisation)
SB$fetchData("k_Volatilisation")

#debugonce(k_WetDeposition)
SB$fetchData("k_WetDeposition")
