#' @title escape
#' @name k_Escape
#' @description calculate k for escape from air compartment to stratosphere based on t_half_Escape
#' @param t_half_Escape Half life time in air [s] 
#' @param SubCompartName considered subcompartment
#' @return k_Escape
#' @export
k_Escape <- function(t_half_Escape, to.SubCompartName, from.SubCompartName){
  # an exclusion of cloudwater is needed as this is now also seen as an air compartment.
  if(to.SubCompartName == "cloudwater") return (NA)
  if(from.SubCompartName == "cloudwater") return (NA)

  switch (to.SubCompartName,
    "air" =   return(log(2)/(t_half_Escape)),
    return(NA)
  )

}
