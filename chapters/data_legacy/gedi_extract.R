# Extract GEDI L2B tracks
# John Godlee (johngodlee@gmail.com)
# 2021-04-21

# Packages 
library(rGEDI)
library(sf)
library(dplyr)
library(ggplot2)

# Import data
bicuar <- st_read("~/google_drive/phd/thesis/tls/dat/site_shp/bicuar/WDPA_Mar2018_protected_area_350-shapefile-polygons.shp")

plots <- read.csv("~/google_drive/phd/thesis/tls/dat/plot_corners.csv")

h5_list <- list.files(".", "*.h5")

# Filter to Bicuar plots
utm_33s <- "+proj=utm +zone=33 +south +ellps=WGS84"

plots_bicuar <- plots %>%
  filter(grepl("ABG", plot_id)) 

plot_centre_bicuar <- plots_bicuar %>%
  group_by(plot_id) %>%
  summarise(
    lon = mean(lon),
    lat = mean(lat)) %>%
  st_as_sf(., coords = c("lon", "lat")) %>%
  st_set_crs(utm_33s)

# Extract shot locations
points_df <- do.call(rbind, lapply(h5_list, function(x) {
  granule <- gsub("_.*", "", gsub(".*_T", "T", x))
  dat <- readLevel2B(x)
  dat_h5 <- dat@h5

  latlong_df <- data.frame(
    granule,
    filename = x,
    lon = dat_h5[["BEAM1011"]][["geolocation/lon_lowestmode"]][],
    lat = dat_h5[["BEAM1011"]][["geolocation/lat_lowestmode"]][],
    shot = dat_h5[["BEAM1011"]][["geolocation/shot_number"]][]
  )
  return(latlong_df)
}))

# Make sf points
points_sf <- st_as_sf(points_df, coords = c("lon", "lat"), 
  na.fail = FALSE) %>%
  st_set_crs(4326)

# Extract Bicuar bounding box
bicuar_bbox <- st_bbox(bicuar) 

# Crop points to bounding box
points_crop <- st_crop(points_sf, bicuar_bbox)

# Make UTM
points_utm <- st_transform(points_crop, utm_33s)

# 25 m radius buffer
polys_utm <- st_buffer(paths_utm, 25)

# Make tracks
lines_utm <- points_utm[seq(1,nrow(points_utm), 10),] %>% 
  group_by(granule) %>% 
  summarise() %>%
  st_cast("LINESTRING")

tracks <- st_buffer(lines_utm, 25)

# Plot tracks in Bicuar
pdf(file = "img/bicuar_tracks.pdf", width = 8, height = 5)
ggplot() + 
  geom_sf(data = bicuar) + 
  geom_sf(data = plot_centre_bicuar, size = 4, shape = 21, colour = "black", 
    fill = "#E15759") + 
  geom_sf(data = tracks, aes(group = granule), 
    fill = "#22a218", colour = "#22a218", alpha = 0.5) + 
  theme_bw() + 
  theme(legend.position = "none")
dev.off()

# Write points to file
saveRDS(points_sf, "dat/bicuar_points.rds")

