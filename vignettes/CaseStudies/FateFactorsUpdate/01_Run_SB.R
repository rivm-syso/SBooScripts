    pol <- plastic_values$polymer_type[i]
    
    variable_df <- data.frame(varName = "RhoS",
                              Waarde = plastic_values$density_average[i])
    
    World$mutateVars(variable_df)
    World$UpdateDirty(unique(variable_df$varName))
    
    World$NewSolver("SteadyStateSolver")
    World$Solve(emissions = emissions)
    
    Masses <- World$Masses()
    
    Masses_grouped_over_species <- Masses |>
      left_join(states, by = "Abbr") |>
      group_by(Scale, SubCompart) |>
      summarise(Mass_kg = sum(Mass_kg))
    
    
  }
}



















# remove_advection <- data.frame(varName = "x_Advection_Air", 
#                                fromScale = "Continental",
#                                toScale = "Moderate",
#                                fromSubCompart = "air",
#                                toSubCompart = "air",
#                                Waarde = 0)
# 
# World$mutateVars(remove_advection)
# 
# World$fetchData("x_Advection_Air")
# 
# World$UpdateDirty(unique(remove_advection$varName))
# 
# World$fetchData("x_Advection_Air")



