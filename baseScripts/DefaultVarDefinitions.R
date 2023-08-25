#This script initialises the default variables
if (!exists("World")) {
  stop("This scripts expects the variable World initialised as in initWorld.R")
}
if ("sboo" %in% loadedNamespaces) {
  #obtain all functions in the SBoo package
  lsf.str(sboo)
  #All variables in the sboo package are compiled and are functions , and need adding as SB variables
  #TODO
} else { # assume FakeLib is run and sboo source is in ../sboo
  
}


World$UpdateKaas()
