#' @title v_OtherkAir
#' @name v_OtherkAir
#' @param all.kaas sneaky way to obtain other loss processes from air
#' @export
OtherkAir <- function (all.kaas){
  return(data.frame(
      Scale = all.kaas$fromScale[all.kaas$fromSubCompart == "air"],
      Species = all.kaas$fromSpecies[all.kaas$fromSubCompart == "air"],
      OtherkAir = all.kaas$k[all.kaas$fromSubCompart == "air"]
    ))
}
