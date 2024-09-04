source("baseScripts/initWorld_onlyMolec.R")

kaas1 <- World$kaas

df <- World$fetchData("MW")

print(df)

sample_df <- data.frame(varName = "MW",
                        Waarde = 1) # In g/mol, will be converted to SI unit (kg/mol) in the core. 


uniqvNames <- unique(sample_df$varName)
World$mutateVars(sample_df)
World$UpdateDirty(uniqvNames)
#World$UpdateKaas(mergeExisting = F)

val2 <- World$fetchData("MW")

kaas2 <- World$kaas

# Left join
kaas3 <- merge(kaas1, kaas2, by = c("process", "fromScale", "fromSubCompart", "fromSpecies", "toScale", "toSubCompart", "toSpecies"), all.x = TRUE)

# Check if there is a difference
kaas3 <- kaas3 |>
  mutate(diff = k.y-k.x)


ur <- list(MW = list(5000.0))
ur[[1]] <- ur[[1]][[1]]

ur$MW <- ur$MW[[1]]
