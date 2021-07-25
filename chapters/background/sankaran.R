# Plot Sankaran et al. 2005 woody cover ~ precip. data
# John Godlee (johngodlee@gmail.com)
# 2021-04-26

library(dplyr)
library(ggplot2)
library(scales)
library(sf)
library(quantreg)

# Import data
sankaran <- read.csv("dat/woody_cover_20070206.csv")

whitesveg <- st_read("/Volumes/john/whiteveg/whiteveg_poly_joined.shp") %>%
  st_set_crs(4326)

gap_frac <- read.csv("/Users/johngodlee/google_drive/phd/thesis/tls/dat/gap_frac.csv") %>%
  filter(method == "tls") %>%
  group_by(plot_id) %>%
  summarise(gap_frac_median = 100 * median(cover, na.rm = TRUE))

bicuar <- read.csv("../introduction/dat/plots_spatial.csv") %>%
  filter(grepl("ABG", plot_id)) %>%
  left_join(., gap_frac, "plot_id")

# Clean data
sankaran_clean <- sankaran %>%
  filter(!row_number() %in% 1) %>%
  dplyr::select(
    lat = Lat, 
    lon = Long, 
    map = MAP,
    cover = Woody_cover) %>%
  mutate(across(everything(), ~as.numeric(.x))) %>%
  st_as_sf(., coords = c("lon", "lat")) %>%
  st_set_crs(4326) %>%
  st_join(., whitesveg)

# Estimate broken-stick max tree cover
rqfit_arid <- data.frame(map = seq(101, 650, 1))
rqfit_arid$arid <- 0.14 * rqfit_arid$map - 14.2

rqfit_mesic <- data.frame(map = seq(650, max(sankaran_clean$map)))
rqfit_mesic$mesic <- rep(80, times = nrow(rqfit_mesic))

# Just points
pdf(file = "img/map_cover_plain.pdf", width = 6, height = 4)
ggplot() + 
  geom_point(data = sankaran_clean, 
    aes(x = map, y = cover), 
    size = 2, fill = alpha("black", 0.5), shape = 21) +
  geom_line(data = rqfit_arid,
    aes(x = map, y = arid)) + 
  geom_line(data = rqfit_mesic,
    aes(x = map, y = mesic)) + 
  labs(x = "MAP (mm)", y = "Woody Cover (%)") + 
  theme_bw()
dev.off()

# Points with White's veg map
pdf(file = "img/map_cover_whitesveg.pdf", width = 8, height = 4)
ggplot() + 
  geom_point(data = sankaran_clean, 
    aes(x = map, y = cover, fill = leg_short_), 
    size = 2, shape = 21) +
  scale_fill_discrete(name = "White's veg. map") + 
  labs(x = "MAP (mm)", y = "Woody Cover (%)") + 
  theme_bw()  
dev.off()

# Points with Bicuar
pdf(file = "img/map_cover_bicuar.pdf", width = 6, height = 4)
ggplot() + 
  geom_point(data = sankaran_clean, 
    aes(x = map, y = cover), 
    size = 2, fill = alpha("black", 0.5), shape = 21) +
  geom_point(data = bicuar, 
    aes(x = bio12, y = gap_frac_median), 
    size = 3, fill = "#E15759", shape = 21) +
  scale_fill_discrete(name = "White's veg. map") + 
  labs(x = "MAP (mm)", y = "Woody Cover (%)") + 
  theme_bw()  
dev.off()
