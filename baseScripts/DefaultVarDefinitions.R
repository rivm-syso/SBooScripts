#This script initialises the default variables
if (!exists("World")) {
  stop("This scripts expects the variable World initialised as in initWorld.R")
}
if ("SBoo" %in% loadedNamespaces) {
  #obtain all functions in the SBoo package
  lsf.str(SBoo)
  #All variables in the SBoo package are compiled and are functions , and need adding as SB variables
  #TODO
} else { # assume FakeLib is run and SBoo source is in ../SBoo
  
}


World$UpdateKaas()
