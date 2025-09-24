#'@title Kp for water colloids
#'@name KpCOL
#'@description partitioning coefficient for water colloids
#'@param  D octanol/water partitioning coefficient at neutral pH for colloids [-]
#'@param Matrix the medium, the formula is only applicable to soil and sediment
#'@export
KpCOL <- function(D, Matrix){
  if (Matrix %in% c("water")) {
    return(
      0.08*D
    )
  } else return (NA)
}
