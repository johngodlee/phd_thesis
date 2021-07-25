# Stats on Zambian ILUAii
# John Godlee (johngodlee@gmail.com)
# 2021-05-17

# Packages
library(dplyr)

# Import data
plots <- read.csv("~/git_proj/seosaw_data/data_out/v2.12/plots_latest_v2.12.csv")

# Number of plots in Zambia
sprintf("%d/%d", nrow(plots[grepl("ZIS", plots$plot_id),]), nrow(plots))

# ha area
sprintf("%.0f/%.0f", sum(plots[grepl("ZIS", plots$plot_id), "plot_area"]), 
  sum(plots$plot_area))


