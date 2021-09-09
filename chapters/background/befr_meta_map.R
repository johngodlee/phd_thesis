# Map of BEFR studies in meta-analyses
# John Godlee (johngodlee@gmail.com)
# 2021-09-07

# Packages
library(sf)
library(dplyr)
library(ggplot2)
library(rnaturalearth)
library(raster)

# Import data
#clarke <- read.csv("clarke.csv")
#liang <- read.csv("liang.csv")
#duffy <- read.csv("duffy.csv")

# Get world map
world <- ne_countries(returnclass = "sf") %>%
  filter(continent != "Antarctica")

# Clean data
#clarke_clean <- clarke %>%
#  mutate(paper = "Clarke") %>%
#  dplyr::select(
#    paper,
#    lat = Latitude,
#    lon = Longitude)
#
#liang_clean <- liang %>% 
#  mutate(paper = "Liang") %>%
#  dplyr::select(
#    paper,
#    lat = Lat, 
#    lon = Lon)
#
#duffy_clean <- duffy %>% 
#  mutate(paper = "Duffy") %>%
#  dplyr::select(
#    paper,
#    lat = latitude, 
#    lon = longitude) %>%
#  filter(lat > -70)
#
#coord_all <- list(clarke_clean, liang_clean, duffy_clean)
#
#saveRDS(coord_all, "dat/coord_all.rds")
coord_all <- readRDS("dat/coord_all.rds")

coord_all_rast <- lapply(coord_all, function(x) {
  x_sf <- st_as_sf(x[,2:3], coords = c("lon", "lat")) %>%
    st_set_crs(4326)

  x_rast <- raster(crs = crs(x_sf), vals = 0, 
    resolution = c(1,1), ext = extent(c(-180, 180, -90, 90))) %>%
    rasterize(x_sf, .) %>% 
    as(., "SpatialPixelsDataFrame") %>%
    as.data.frame(.)

  return(x_rast)
})

# Plot
map <- ggplot() + 
  geom_sf(data = world, colour = "black", fill = NA, size = 0.25) + 
  geom_tile(data = coord_all_rast[[2]], aes(x = x, y = y),
    fill = "darkgreen", alpha = 1) + 
  geom_tile(data = coord_all_rast[[3]], aes(x = x, y = y),
    fill = "darkred", alpha = 1) + 
  geom_tile(data = coord_all_rast[[1]], aes(x = x, y = y),
    fill = "darkblue", alpha = 1) + 
  theme_void() + 
  theme(legend.position = "none") 

pdf(file = "img/befr_map.pdf", width = 8, height = 3.5)
map
dev.off()

