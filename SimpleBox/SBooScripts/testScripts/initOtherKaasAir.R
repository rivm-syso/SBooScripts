


World$NewCalcVariable("Tempfactor")
World$CalcVar("Tempfactor")

World$NewCalcVariable("KdegDorC")
World$CalcVar("KdegDorC")

testClass <- World$NewProcess("k_Degradation")
testClass$execute()

testClass <- World$NewProcess("k_Escape")
testClass$execute()

#Advection Ks still missing

# testClass <- World$NewProcess("k_Advection")
# testClass$execute()
