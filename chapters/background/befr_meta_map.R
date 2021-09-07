# Map of BEFR studies in meta-analyses
# John Godlee (johngodlee@gmail.com)
# 2021-09-07

# Packages
library(sf)
library(dplyr)
library(ggplot2)
library(rnaturalearth)

# Import data
clarke <- read.csv("clarke.csv")
liang <- read.csv("liang.csv")
duffy <- read.csv("duffy.csv")

# Get world map
world <- ne_countries(returnclass = "sf") %>%
  filter(continent != "Antarctica")

# Clean data
clarke_clean <- clarke %>%
  mutate(paper = "Clarke") %>%
  dplyr::select(
    paper,
    lat = Latitude,
    lon = Longitude)

liang_clean <- liang %>% 
  mutate(paper = "Liang") %>%
  dplyr::select(
    paper,
    lat = Lat, 
    lon = Lon)

duffy_clean <- duffy %>% 
  mutate(paper = "Duffy") %>%
  dplyr::select(
    paper,
    lat = latitude, 
    lon = longitude) %>%
  filter(lat > -70)

coord_all <- list(clarke_clean, liang_clean, duffy_clean)

saveRDS(coord_all, "dat/coord_all.rds")
coord_all <- readRDS("dat/coord_all.rds")

# Plot
map <- ggplot() + 
  geom_sf(data = world, colour = "black", fill = NA, size = 0.25) + 
  geom_point(data = coord_all[[2]], aes(x = lon, y = lat),
    fill = "green",
    alpha = 0.7, shape = 21) + 
  geom_point(data = coord_all[[3]], aes(x = lon, y = lat),
    fill = "red",
    alpha = 0.7, shape = 21) + 
  geom_point(data = coord_all[[1]], aes(x = lon, y = lat),
    fill = "blue",
    alpha = 0.7, shape = 21) + 
  theme_void() + 
  theme(legend.position = "none") 

ggsave("befr_map.png", map, dpi = 600)
