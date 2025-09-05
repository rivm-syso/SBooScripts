##Plot steadystate
#Function to plot from iteration

# plot <- function(concentration, masses, state='Undefined') {
#   
# 
#   
#   # solution <- World$Masses()
#   # emission <- World$Emissions()
#   # concentration <- World$Concentration()

staaf_plot <- function (data, scale, compartiment='',  x_label = '', y_label ='', title='', text_angle = 45, relative_mass=FALSE, limits=NULL) {
  convert_labels <- c("w0RU" = "Oppervlakte Water", "w1RU" = "Rivier", "w2RU" = "Zee", 
                      "sd0RU" = "Sediment Opp. W", "sd1RU" = "Sediment Rivier", 
                      "sd2RU" =  "Sediment Zee", "s1RU" = "Natuurlijke Bodem", 
                      "s2RU" = "Agrarische Bodem", "s3RU" = "Overige Bodem")
  if (scale == 'Continental') {
    names(convert_labels) <- gsub("R", "C", names(convert_labels))
    data = filter(data, grepl("C", Abbr))
  }
  if (scale == 'Regional') {
    data = filter(data, grepl("R", Abbr))
  }
  if (compartiment != '') {
    data = filter(data, grepl(compartiment, Abbr))
  }
  
  
  plot <- ggplot(data, aes(x = Abbr, y = data[,2])) +
    geom_bar(stat = "identity", position = "dodge") +
    #scale_y_log10() +
    labs(
      title=title,
      x = x_label,
      y = y_label
    ) +
    theme(axis.text.x = element_text(angle = text_angle, hjust = 1),
          legend.position = "none") +
    scale_x_discrete(labels = convert_labels)
  
  if (!is.null(limits) && length(limits) == 2) {
    ylim_lower <- limits[1]
    ylim_upper <- limits[2]
    plot <- plot + coord_cartesian(ylim = c(ylim_lower, ylim_upper))
  } else {
    ylim_lower <- NULL
    ylim_upper <- NULL
  }
  return(plot)
}

#   staaf_plot1 = staaf_plot(concentration, 'Regional', 'Compartimenten', 'concentratie', 'Concentraties')
#   staaf_plot1
#   
#   
#   ##Plot dynamic
# }


