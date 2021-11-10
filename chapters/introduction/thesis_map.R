# Map of spatial scales of thesis structure
# John Godlee (johngodlee@gmail.com)
# 2021-05-17

library(ggplot2)
library(seosawr)
library(ggrepel)
library(sf)
library(rnaturalearth)
library(dplyr)
library(shades)

# Import data

data(seosaw_region)

africa <- ne_countries(scale = "medium", returnclass = "sf") %>%
  filter(continent == "Africa")

# Import data
# Create a bounding box for Southern Africa
y_max <- africa %>% 
  filter(sov_a3 == "KEN") %>% 
  st_bbox() %>% 
  as.vector() %>% 
  `[`(4)

x_max <- africa %>%
  filter(sov_a3 == "KEN") %>%
  st_bbox() %>%
  as.vector() %>%
  `[`(3)

y_min <- -35

x_min <- africa %>%
  filter(sov_a3 == "COG") %>%
  st_bbox() %>%
  as.vector() %>%
  `[`(1)

africa_bbox <- st_bbox(africa)

africa_bbox[1] <- x_min
africa_bbox[2] <- y_min
africa_bbox[3] <- x_max
africa_bbox[4] <- y_max

# Crop africa countries to bbox
saf <- st_crop(st_make_valid(africa), africa_bbox)

# Get Zambia 
zmb <- saf %>%
  filter(admin == "Zambia")

# Get Bicuar and Mtarure locations
tls <- data.frame(
  id = c("Bicuar", "Bicuar", "Mtarure"), 
  ch = c("5", "7", "5"),
  lon = c(14.81, 14.81, 39.00),
  lat = c(-15.29, -15.29, -8.972))

# Crop SEOSAW region
seosaw_region_crop <- st_crop(seosaw_region, saf)

# Zambia centroid label
zmb_ctd <- as.data.frame(st_coordinates(st_centroid(zmb)))
zmb_ctd$ch <- "4"

# SEOSAW region label
seosaw_lab <- data.frame(lon = 40, lat = -20, ch = "3")

# Create plot
thesis_map <- ggplot() + 
  geom_sf(data = saf, 
    colour = NA, fill = "lightgray") + 
  geom_sf(data = seosaw_region_crop, 
    colour = "black", fill = "#D65F5F") + 
  geom_label(data = seosaw_lab, 
    aes(x = lon, y = lat, label = ch),
    size = 6, fill = "#D65F5F") + 
  geom_sf(data = saf, 
    colour = "black", fill = NA) + 
  geom_sf(data = zmb, 
    fill = "#377EB8", colour = "black", alpha = 0.8) + 
  geom_label(data = zmb_ctd, aes(x = X, y = Y, label = ch), 
    fill= "#377EB8", size = 6) + 
  geom_label_repel(data = tls, 
    aes(x = lon, y = lat, label = ch, fill = ch),
    point.padding = 0, box.padding = 0, size = 6) + 
  scale_fill_manual(values = c("#4daf4a", "#ffce86")) + 
  theme_bw() + 
  theme(legend.position = "none") + 
  labs(x = "", y = "")

pdf(file = "img/thesis_map.pdf", width = 6, height = 8)
thesis_map
dev.off()
