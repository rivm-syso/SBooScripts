#' @title Dimensionless air/water partitioning coefficient of molecular species specific to air compartment (scale)
#' @name Kacompw
#' @description assess the Kaw if it's not given, if Pvap25 is NA or too large, MaxPvap is used
#' @param Pvap25 vapor pressure of original species at 25 C [Pa]
#' @param MaxPvap maximum vapor pressure of original species at 25 C [Pa]
#' @param ChemClass chemical class, see QSAR table
#' @param Sol25 water solubility of original species at 25 C [mol.m-3]
#' @param H0sol Enthalpy of dissolution [-]
#' @param T25 const (25 C ==) 298 K [K]
#' @param Tm melting temp [K]
#' @param Tm_default default melting point if melting temperature is not given [K]
#' @param Temp temperature of compartment [K]
#' @param MW molar weight[kg mol-1]
#' @param Test  determines if SB4-Excel approach is taken or enhanced method from R version [boolean]
#' @return Kacompw
#' @export
Kacompw <- function(Kaw25,
                    ChemClass,
                    Pvap25,
                    Sol25,
                    H0sol,
                    MaxPvap,
                    T25,
                    Tm, Tm_default,
                    Temp,
                    MW,
                    Test) {
  # easy reading kBolts as R

  if (ChemClass == "particle") {
    return(NA)
  } else {
    if (as.character(Test) == "TRUE") {
      R <- 8.314
      # Pvap25 <- 0.0000278666666597 # Was only used for testing 1-HTDROXYANTHRAQUINONE (to make pvap25 val the same as excel)
    } else {
      R <- getConst("r")
    }

    # Not in the data
    H0vap <- NA

    # precaution, cannot be larger than, nor NA
    # CalcPvap25 <- max(ifelse(is.na(Pvap25),MaxPvap,Pvap25), MaxPvap)

    # The actual
    if (is.na(Kaw25) || Kaw25 == "NA") {
      Kaw25 <- switch(ChemClass,
        "metal" = 1E-20,
        "particle" = 1e-20,
        max(
          ifelse(Pvap25 > MaxPvap,
            (MaxPvap / (Sol25 / MW)) / (R * T25),
            (Pvap25 / (Sol25 / MW)) / (R * T25)
          ),
          1E-20
        ) # yet another precaution for too small Kaw and too high Pvap25.
      )
    }

    # For some metals, pvap25 is missing. In those cases, Pvap25 is set to 4 (same value as in excel, median of all Pvaps)
    if ((is.na(Pvap25) || Pvap25 == "NA") && ChemClass == "metal") {
      Pvap25 <- 4
    }

    if (is.na(H0vap) || H0vap == "NA") { # only used for Kaw
      # this depends on Pvap25, Tm:
      if ((is.na(Tm) || Tm == "NA")) Tm <- Tm_default
      H0vap <- 1000 * (-3.82 * log(ifelse(Tm > 298, Pvap25 * exp(-6.79 * (1 - Tm / T25)), Pvap25)) + 70)
    }

    if (is.na(H0sol) || H0sol == "NA") stop("H0sol is missing")

    if (is.na(Pvap25) || Pvap25 == "NA") stop("Pvap25 is missing")

    Kaw25 * exp((H0vap / R) * (1 / T25 - 1 / Temp)) * exp(-(H0sol / R) * (1 / T25 - 1 / Temp)) * (T25 / Temp)
  }
}
