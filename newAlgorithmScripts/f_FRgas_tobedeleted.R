#' @title FRgas
#' @name FRgas
#' @description 1 - the other fractions
#' @param FRearw 
#' @param FRgas 
#' @return FRgas[]
#' @export
FRgas <- function(FRearw, FRears, ...){ #, FRcldw
  1 - FRearw - FRears
}

