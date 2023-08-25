#init default core (World) with classic states, and classic kaas
source("baseScripts/initTestWorld.R")
World$doInherit(fromData = "DefaultpH", toData = "pH")
World$doInherit(fromData = "DefaultNETsedrate", toData = "NETsedrate")
#debugonce(World$doInherit)
