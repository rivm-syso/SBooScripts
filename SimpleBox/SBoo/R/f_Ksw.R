#'@title soil water partitioning coefficient
#'@name f_Ksw
#'@description Calculates the Ksw based on QSARS (Franco & Trapp, 2008) (https://doi.org/10.1897/07-583.1)
#'@param ChemClass Class of chemical, see QSAR table (REACH, 2012)
#'@param Kow octanol water partitioning coefficient [-]
#'@param CorgStandard Standard mass FRACTION organic carbon in soil/sediment [-]
#'@param a see QSAR table 
#'@param b see QSAR table 
#'@param RHOsolid density of "solids" [kg/m3]
#'@param alt_form the alternate form. 
#'@param Ksw_orig soil water partitioning coefficient as present in the data [-]
#'@return Ksw
#'@export
f_Ksw <- function(Kow, pKa, CorgStandard , a, b, ChemClass, RHOsolid, alt_form, Ksw_orig){

  ifelse(alt_form,
         # TRUE, so the alt_form
         switch(ChemClass,
                "acid" = 10^(0.11*log10(Kow)+1.54) * CorgStandard * RHOsolid / 1000,
                "base" = 10^(pKa^0.65*(Kow/(1+Kow))^0.14) * CorgStandard * RHOsolid / 1000,
                #else
                {a * Kow^b * CorgStandard * RHOsolid / 1000}      
         ),
         # FALSE, NB not the alt_form
      switch(ChemClass,
          "acid" = 10^(0.54*log10(Kow)+1.11) * CorgStandard * RHOsolid / 1000,
          "base" = 10^(0.37*log10(Kow)+1.7) * CorgStandard * RHOsolid / 1000,
          "metal" = stop("Ksw Should be in the data"),
          #"particle" = stop("Ksw Should be in the data"),
          "particle" = NA,
          #else
          {a * Kow^b * CorgStandard * RHOsolid / 1000}
      )
    )
}
