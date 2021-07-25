# Reclassify ESA CCI land cover around Bicuar National Park
# John Godlee (johngodlee@gmail.com)
# 2021-05-21

# Packages
library(raster)
library(sf)
library(dplyr)
library(ggplot2)

# Import data
cci <- raster("/Volumes/john/esa_cci_land_cover/ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7.tif")

bicuar <- st_read("../bicuar_shp/WDPA_Mar2018_protected_area_350-shapefile-polygons.shp")

# Define extent of map
extent(bicuar)

cci_bicuar <- crop(cci, 
  extent(bicuar) + c(-0.1, 0.1, -0.1, 0.1))

# Convert raster to dataframe 
cci_bicuar_spdf <- as(cci_bicuar, "SpatialPixelsDataFrame")
cci_bicuar_df <- as.data.frame(cci_bicuar_spdf)
colnames(cci_bicuar_df) <- c("value", "x", "y")

# Reclassify land cover 
cci_bicuar_df$id <- case_when(
  cci_bicuar_df$value == 10 ~ "Cropland",
  cci_bicuar_df$value == 11 ~ "Grassland",
  cci_bicuar_df$value == 30 ~ "Cropland",
  cci_bicuar_df$value == 40 ~ "Woodland (<40% cover)",
  cci_bicuar_df$value == 60 ~ "Woodland (<40% cover)",
  cci_bicuar_df$value == 61 ~ "Forest (>40% cover)",
  cci_bicuar_df$value == 62 ~ "Woodland (<40% cover)",
  cci_bicuar_df$value == 100 ~ "Grassland",
  cci_bicuar_df$value == 110 ~ "Grassland",
  cci_bicuar_df$value == 120 ~ "Shrubland",
  cci_bicuar_df$value == 122 ~ "Shrubland",
  cci_bicuar_df$value == 130 ~ "Grassland",
  cci_bicuar_df$value == 180 ~ "Shrubland",
  cci_bicuar_df$value == 190 ~ "Urban",
  cci_bicuar_df$value == 210 ~ "Water",
  TRUE ~ NA_character_)

cci_bicuar_df$id <- factor(cci_bicuar_df$id, levels = 
  c("Cropland", "Grassland", "Shrubland", 
    "Woodland (<40% cover)", "Forest (>40% cover)", "Urban", "Water"))

# Define colour palette
pal <- c(
  "Cropland" = "#ffff64",
  "Woodland (<40% cover)" = "#8ca000",
  "Forest (>40% cover)" = "#006400",
  "Shrubland" = "#966400",
  "Grassland" = "#ffb432",
  "Urban" = "#c31400",
  "Water" = "#0046c8")

# Write map
pdf(file = "bicuar_land_cover.pdf", width = 8, height = 5)
ggplot() + 
  geom_tile(data = cci_bicuar_df, aes(x = x, y = y, fill = id)) + 
  scale_fill_manual(name = "Land cover", values = pal) + 
  geom_sf(data = bicuar, fill = NA, colour = "black") + 
  theme_bw() + 
  labs(x = "", y = "")
dev.off()
