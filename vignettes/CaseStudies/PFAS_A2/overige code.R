
#Code voor testje correctie
solution_on_off <- concentration_off %>%
  inner_join(concentration_on, by=c("time", "Abbr")) %>%
  filter(grepl("s[0-9]", Abbr)) %>%
  filter(grepl("R", Abbr)) %>%
  rename('CorrSoil Off' = Concentration.x, 'CorrSoil On' = Concentration.y) %>%
  pivot_longer(cols = c('CorrSoil Off', 'CorrSoil On'), 
               names_to = "source", 
               values_to = "Concentration") %>%
  mutate(year = 1950 + as.numeric(time) / 31557600)


ggplot(solution_on_off, aes(x = year, y = Concentration, color = source)) +
  geom_line() +
  facet_wrap(~ Abbr) +
  labs(title = "Concentratie per categorie",
       x = "Jaar",
       y = "Concentratie g/kg",
       color = "Bron") +
  theme_minimal()

on = staaf_plot(data=concentration, scale="Regional", compartiment = 'sd', title="f_CORRsoil return 1", limits = c(0, 0.000009), y_label = 'concentratie')
off = staaf_plot(data=concentration_off, scale="Regional", compartiment = 'sd', title="f_CORRsoil returns default", limits = c(0, 0.000009), y_label='concentratie')
on + off

#New solver
#World$NewSolver("DynamicSolver")
#World$Solve(emissions = emissions, tmax = tmax, nTIMES = nTIMES)
