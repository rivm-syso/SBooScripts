# Plot function for Mass Balance check

test_MassBalance$version <- "new"
main_MassBalance$version <- "previous"

Plot_Mass_Balance <- function(MassBalanceCheck = test_MassBalance){

ggplot(MassBalanceCheck |> 
         pivot_longer(!c(Compartment,Substance),
                      names_to = "Flow",
                      values_to = "Mass flow (kg/s)"), 
       aes(x = Compartment, y = `Mass flow (kg/s)`, fill = Flow)) +
  geom_bar(stat = "identity", position = "stack") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5),
    panel.grid.major.y = element_line(color = "grey80", size = 0.7),
    panel.grid.minor.y = element_line(color = "grey90", size = 0.5)
  ) +
  scale_y_continuous(breaks = scales::extended_breaks(20))
}


rbind(main_MassBalance,test_MassBalance)

Plot_Mass_Balance <- function(MassBalanceCheck = test_MassBalance){
  
  ggplot(MassBalanceCheck, 
         aes(x = Compartment, y = Diff_Flows, fill = Substance)) +
    geom_bar(stat = "identity", position = "dodge") +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 90, vjust = 0.5),
      panel.grid.major.y = element_line(color = "grey80", size = 0.7),
      panel.grid.minor.y = element_line(color = "grey90", size = 0.5)
    ) +
    scale_y_continuous(breaks = scales::extended_breaks(20))
}



ggplot(rbind(main_MassBalance,test_MassBalance), 
       aes(x = Compartment, y = Diff_Flows, fill = Substance)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~version) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5),
    panel.grid.major.y = element_line(color = "grey80", size = 0.7),
    panel.grid.minor.y = element_line(color = "grey90", size = 0.5)
  ) +
  scale_y_continuous(breaks = scales::extended_breaks(20))

ggplot(MassBalanceCheck |> 
         mutate(Trans_from = -1*Trans_from,
                Removal_kg_s = -1*Removal_kg_s) |> 
         pivot_longer(!c(Compartment,Substance),
                      names_to = "Flow",
                      values_to = "Mass flow (kg/s)") , 
       aes(x = Compartment, y = `Mass flow (kg/s)`, fill = Flow)) +
  geom_bar(stat = "identity", position = "stack") +
  facet_wrap(~Substance) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5),
    panel.grid.major.y = element_line(color = "grey80", size = 0.7),
    panel.grid.minor.y = element_line(color = "grey90", size = 0.5)
  ) +
  scale_y_continuous(breaks = scales::extended_breaks(20))

