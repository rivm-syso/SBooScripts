#' @title Advection of fluxes of air between scales 
#' @name x_Advection_air
#' @description Calculation using AirFlow, but adjust to mass balance volume flows
#' @param all.AirFlow to pick for the "from" scale 
#' @param from.ScaleName name of the scale of the source of the process
#' @param to.ScaleName name of the scale of the destination of the process
#' @return x.Advection_Air, the flow
#' @export
x_Advection_Air <- function(all.AirFlow, from.ScaleName, to.ScaleName){
  # The airflow was step 1; now the corrections for the mass balance to add up..
  # "normal" k is 1/Tau ;  Airflow = Volume/Tau
  
  from.AirFlow <- all.AirFlow$AirFlow[all.AirFlow$Scale == from.ScaleName] #if also for cloudwater, include subcompart in clause
  to.Airflow <- all.AirFlow$AirFlow[all.AirFlow$Scale == to.ScaleName]
  #local function to fetch airflow between continental to Regional, neither of which are from or to
  Cont2Regional.Airflow <- function(){
    all.AirFlow$AirFlow[all.AirFlow$Scale == "Regional"] # & All.Airflow$SubCompart =="air"
  }

  if(from.ScaleName %in% c("Arctic", "Regional", "Tropic")){
    return(all.AirFlow$AirFlow[all.AirFlow$Scale == from.ScaleName])
  }
  
  if(from.ScaleName == "Continental" & to.ScaleName == "Moderate"){
    #the actual Airflow needs correcting 
    return(all.AirFlow$AirFlow[all.AirFlow$Scale == from.ScaleName] - Cont2Regional.Airflow())
  } 
  
  if(from.ScaleName == "Moderate" & to.ScaleName == "Continental"){
    #the actual Airflow needs correcting 
    return(all.AirFlow$AirFlow[all.AirFlow$Scale == to.ScaleName] - Cont2Regional.Airflow())
  } 
  
  # else from is set to the to.AirFlow, keeping the mass balance;
  return(all.AirFlow$AirFlow[all.AirFlow$Scale == to.ScaleName])
}