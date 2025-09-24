library(tidyverse)

#script to initialize test environment faking library(SBoo)
source("baseScripts/fakeLib.R")

NewstateModule <- ClassicNanoWorld$new("data", "Ag(I)")

#with this data we create an instance of the central "core" object,
World <- SBcore$new(NewstateModule)

#reading data from the excel version(s) resembles the process class 
ClassicClass <- ClassicNanoProcess$new(TheCore = World, filename = "data/SimpleBox4.01_20211028.xlsm")
#ClassicClass <- ClassicNanoProcess$new(TheCore = World, filename = "data/20210331 SimpleBox4nano_rev006.xlsx")

#interpret the excel-file and apply the k's 
World$UpdateKaas(ClassicClass)

ToPivot <- World$kaas[,c("fromScale", "fromSubCompart", "fromSpecies", "toScale", "toSubCompart")]
# transfers (a k) from a compartment to another (toSubCompart > "");
# pivot; new column names are "fromSubCompart" - same as engine in excel, we count 5 transfers from air to sea
ToPivot %>% filter(toSubCompart > "") %>% 
  select(toSubCompart, fromSubCompart) %>% group_by(toSubCompart, fromSubCompart) %>% summarise(n = n()) %>%
  pivot_wider(values_from = "n", id_cols = "toSubCompart", names_from = "fromSubCompart") %>%
  relocate(sort(unique(ToPivot$fromSubCompart)), .after = last_col())

volat <- ClassicClass$Excelgrep("Volat")
MTCs <- ClassicClass$Excelgrep("MTC")
#flows <- flows[flows$Scale %in% c("Regional", "Continental"),]
flows[,c("Scale","Scale.1","SubCompart","SubCompart.1","varName", "FormValue")]
All2Nodes <- ClassicClass$Exceldependencies(flows$varName, maxDepth = 2)
#filter interesting part
asDF <- igraph::as_data_frame(All2Nodes)  #as.data.frame(All2Nodes)
asDF <- asDF[grep("\\.aR", asDF$from) ,]
#add the k-part to complete
k_part <- ClassicClass$Exceltrace(asDF$to, maxDepth = 2)
k_part <- igraph::as_data_frame(k_part)  

plot(igraph::graph_from_data_frame(unique(rbind(asDF, k_part))))
#debugonce(ClassicClass$Exceltrace)

ClassicClass$Excelgrep("MTCas.air")
