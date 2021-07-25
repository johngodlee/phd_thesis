# Identify numbers of large trees in LiDAR plots
# John Godlee (johngodlee@gmail.com)
# 2021-05-14

# Packages
library(dplyr)

# Import data
dat <- read.csv("../tls/dat/stems_all.csv")

# Numbers of large trees per plot
dat %>% 
  filter(diam >= 50) %>%
  tally()
