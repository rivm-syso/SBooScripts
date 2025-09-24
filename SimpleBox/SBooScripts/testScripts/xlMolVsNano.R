#RipExcel
#This script demonstrates how to find the logic in excel, and 
#compares the molecular version with nano 

#script to faking the future library(SBoo)
source("baseScripts/fakeLib.R")

#We need a landscape, to create a "World"
NewstateModule <- ClassicNanoWorld$new("data", "Ag(I)")
World <- SBcore$new(NewstateModule)

#Old school excel is analysed using R, reading all the cells needs two steps
ClassicClass <- ClassicNanoProcess$new(TheCore = World, filename = "data/SimpleBox4.01_20211028.xlsm")
#apply and replace current kaas with all other reading; that's why ClassicNanoProcess inherits from process
World$UpdateKaas(ClassicClass)

#before reading the nano version we extract all we need from this version. (There )
ClassicNano <- ClassicNanoProcess$new(TheCore = World, filename = "data/20210331 SimpleBox4nano_rev006.xlsx")
#apply and replace current kaas with all other reading; that's why ClassicNanoProcess inherits from process
World$UpdateKaas(ClassicClass)
