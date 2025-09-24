#'@title partial mass transfer coefficient from air to soil 
#'@name MTC_2s
#'@description partial mass transfer coefficient from air to soil 
#'@param Mackay1 constant described by Mackay (2001) [m/s] https://doi.org/10.1201/9781420032543
#'@param Mackay2 constant described by Mackay (2001) [-] https://doi.org/10.1201/9781420032543
#'@param Matrix matrix considered
#'@return MTC_2w
#'@export
MTC_2s <- function(Mackay1, Mackay2, Matrix){
  switch(Matrix,
    "air" =  Mackay1/Mackay2,
    NA
  )
}
