# Make a map of global distribution of savannas / woodlands
# John Godlee (johngodlee@gmail.com)
# 2021-05-21

# Packages
library(sf)
library(nngeo)
library(ggplot2)
library(dplyr)
library(rnaturalearth)

# Import data
teow <- st_read("/Volumes/john/Ecoregions2017/Ecoregions2017.shp")

world <- ne_countries(returnclass = "sf")

# Define tropical latitudes
trop <- 23.5

# Defin proj
carre <- 4087

# Define tropics as bounding box
trop_bbox <- st_bbox(c(xmin = -180, ymin = -trop, xmax = 180, ymax = trop), 
  crs = 4326) %>% 
  st_as_sfc() %>%
  st_transform(., carre)

# Define extra-tropical area as polygons
extratrop_bbox1 <- st_bbox(c(xmin = -180, ymin = trop, xmax = 180, ymax = 90), 
  crs = 4326) %>% 
  st_as_sfc() %>%
  st_transform(., carre)

extratrop_bbox2 <- st_bbox(c(xmin = -180, ymin = -trop, xmax = 180, ymax = -90), 
  crs = 4326) %>% 
  st_as_sfc() %>%
  st_transform(., carre) 

extratrop_bbox <- c(extratrop_bbox1, extratrop_bbox2)

# Make world planar
world_carre <- st_transform(world, carre)

# Make TEOW planar
teow_carre <- st_transform(teow, carre)

# Filter out some polys
teow_fil <- teow_carre %>% 
  dplyr::select(BIOME_NAME) %>%
  filter(BIOME_NAME == "Tropical & Subtropical Grasslands, Savannas & Shrublands")

# Simplify TEOW polygons a little 
teow_valid <- st_buffer(teow_fil, dist = 0)

# Crop TEOW to tropics
teow_trop <- st_intersection(teow_valid, trop_bbox)

teow_extratrop <- st_intersection(teow_valid, extratrop_bbox)

# Dissolve all polygons
teow_diss <- teow_trop %>%
  group_by(BIOME_NAME) %>%
  summarise() %>% 
  st_remove_holes(.)

teow_extratrop_diss <- teow_extratrop %>%
  group_by(BIOME_NAME) %>%
  summarise() %>% 
  st_remove_holes(.)

# Write data 
saveRDS(teow_diss, "dat/teow_savanna_dissolve.rds")
saveRDS(teow_extratrop_diss, "dat/teow_savanna_extratrop_dissolve.rds")
teow_diss <- readRDS("dat/teow_savanna_dissolve.rds")
teow_extratrop_diss <- readRDS("dat/teow_savanna_extratrop_dissolve.rds")

# Dissolve countries
world_diss <- world_carre %>%
  filter(!continent %in% c("Antarctica", "Seven seas (open ocean)")) %>%
  mutate(group = 1) %>%
  group_by(group) %>%
  summarise() %>%
  st_remove_holes() %>%
  st_transform(4326)

# Create plot
pdf(file = "img/savanna_map.pdf", width = 10, height = 5)
ggplot() +
  geom_sf(data = world_diss) +
  geom_sf(data = teow_extratrop_diss, fill = "#806f44", colour = NA) + 
  geom_sf(data = teow_diss, fill = "#DAA51B", colour = NA) + 
  geom_hline(yintercept = c(trop, -trop), linetype = 2) + 
  theme_bw() + 
  labs(x = "", y = "")
dev.off()

