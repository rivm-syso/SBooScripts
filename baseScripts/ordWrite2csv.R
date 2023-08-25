# write sboo data tidied and ordered to csv's
# sourced from different scripts...
# Defs should be vector of names and consistent with that 
# MlikeWorkBook a list of dataframes
sortNames <- c("VarName", "Scale", "Compartment", "SubCompart", "Species", 
               "to.Scale", "to.SubCompart", "to.Species", 
               "Substance", "process", "Matrix", "from", "to", "QSAR.ChemClass")

OutputFolder <- "data/"
#easier to use/debug with for loop, simple is good
for (sheetI in 1 : length(Defs)){ #sheetI = 20
  tableName <- Defs[sheetI]
  tabledata.frame <- MlikeWorkBook[[tableName]]
  #sort by scale compart/subcompart species substance process from to
  orderNames <- sortNames[sortNames %in% names(tabledata.frame)]
  #skip empty lines / columnNames
  CompleteLines <- complete.cases(tabledata.frame[,orderNames])
  WithNames <- names(tabledata.frame) != "" & !is.na(names(tabledata.frame))
  #easier than keeping the index..
  tabledata.frame <- tabledata.frame[CompleteLines, 
                                     names(tabledata.frame)[WithNames]]
  UnorderedNames <- names(tabledata.frame)[!names(tabledata.frame) %in% orderNames]
  #this script should be tidyversed... but it can in base (data.frame IS a list)
  SaveOrder <- do.call(order, tabledata.frame[,orderNames, drop=FALSE])
  #write it, with quotes for non-numeric columns
  WithQuotes <- which(!sapply(tabledata.frame, is.numeric))
  Outputfile <- paste(OutputFolder, tableName, ".csv", sep = "")
  # n.o. digits governed by the option "scipen"?? (see options), but with the internal equivalent of digits = 15
  write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
            file = Outputfile, quote = WithQuotes, row.names = F, dec = ".")
}
