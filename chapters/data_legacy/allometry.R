# Process GlobAllomeTree data and Chave data
# John Godlee (johngodlee@gmail.com)
# 2021-05-21

library(rjson)
library(ggplot2)
library(dplyr)
library(patchwork)

# Import data
dat <- fromJSON(file = "./dat/globallometree_raw.json")
chave <- read.csv("./dat/Chave_GCB_Direct_Harvest_Data.csv")

# Extract data from JSON
dat_df <- do.call(rbind, lapply(dat, function(x) { 
  dbh <- ifelse(is.null(x$DBH_cm), NA_real_, x$DBH_cm)
  abg <- ifelse(is.null(x$ABG_kg), NA_real_, x$ABG_kg)
  sp <- ifelse(is.null(x$Species_group$Group[[1]]$Scientific_name), NA_character_, 
    x$Species_group$Group[[1]]$Scientific_name)
  fam <- ifelse(is.null(x$Species_group$Group[[1]]$Family), NA_character_,  
    x$Species_group$Group[[1]]$Family)
  lon <- ifelse(is.null(x$Location_group$Group[[1]]$Longitude), NA_real_,  
    x$Location_group$Group[[1]]$Longitude)
  lat <- ifelse(is.null(x$Location_group$Group[[1]]$Latitude), NA_real_,  
    x$Location_group$Group[[1]]$Latitude)
  teow <- ifelse(is.null(x$Location_group$Group[[1]]$Ecoregion_Udvardy), NA_character_,  
    x$Location_group$Group[[1]]$Ecoregion_Udvardy)
  country <- ifelse(is.null(x$Location_group$Group[[1]]$Country), NA_character_,  
    x$Location_group$Group[[1]]$Country)
  continent <- ifelse(is.null(x$Location_group$Group[[1]]$Continent), NA_character_,  
    x$Location_group$Group[[1]]$Continent)

  out <- data.frame(dbh, abg, sp, fam, lon, lat, teow, country, continent)

  return(out)
}))

# Exclude a couple of points
fil_df <- dat_df %>%
  mutate(
    abg = as.numeric(abg),
    dbh = as.numeric(dbh)) %>%
  filter(
    abg < 60000,
    !(dbh > 50 & abg < 100),
    !is.na(dbh), !is.na(abg))

# Create plot of Diameter vs. ABG
pdf(file = "img/allometry.pdf", height = 6, width = 8)
ggplot() + 
  geom_point(data = fil_df, aes(x = dbh, y = abg), 
    shape = 21, fill = "darkgrey") + 
  geom_point(data = chave, aes(x = DBH.cm., y = Dry.total.AGB.kg.), 
    shape = 21, fill ="darkgrey") + 
  theme_bw()
dev.off()

# How many valid? 
nrow(fil_df)
nrow(chave)
