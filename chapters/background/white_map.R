# Map of woodland types in southern Africa, according to White
# John Godlee (johngodlee@gmail.com)
# 2021-05-25

# Packages
library(dplyr)
library(sf)
library(ggplot2)
library(patchwork)
library(rnaturalearth)

# Import data
white <- st_read("/Volumes/john/whiteveg/whiteveg_poly_joined.shp")

teow <- st_read("/Volumes/seosaw_spat/teow/Ecoregions2017.shp")

af <- ne_countries(continent = "Africa", returnclass = "sf")

y_max <- af %>% 
  filter(sov_a3 == "KEN") %>% 
  st_bbox() %>% 
  as.vector() %>% 
  `[`(4)

x_max <- af %>%
  filter(sov_a3 == "KEN") %>%
  st_bbox() %>%
  as.vector() %>%
  `[`(3)

y_min <- -35

x_min <- af %>%
  filter(sov_a3 == "COG") %>%
  st_bbox() %>%
  as.vector() %>%
  `[`(1)

africa_bbox <- st_bbox(af)

africa_bbox[1] <- x_min
africa_bbox[2] <- y_min
africa_bbox[3] <- x_max
africa_bbox[4] <- y_max

# Crop africa countries to bbox
saf <- st_crop(af, africa_bbox)

white_crop <- st_crop(st_make_valid(white), saf) %>%
  filter(!leg_MAJOR_ %in% c("WATER", "OUTSIDE AREA")) %>%
  mutate(leg_MAJOR_ = case_when(
    leg_MAJOR_ == "ALTIMONTANE VEGETATION" ~ "Montane",
    leg_MAJOR_ == "AZONAL VEGETATION" ~ "Azonal vegetation",
    leg_MAJOR_ == "BUSHLAND AND THICKET" ~ "Bushland, thicket",
    leg_MAJOR_ == "BUSHLAND AND THICKET MOSAICS" ~ "Bushland, thicket",
    leg_MAJOR_ == "CAPE SHRUBLAND" ~ "Grassland, shrubland",
    leg_MAJOR_ == "DESERT" ~ "Desert, semi-desert",
    leg_MAJOR_ == "EDAPHIC GRASSLAND MOSAICS" ~ "Grassland, shrubland",
    leg_MAJOR_ == "FOREST" ~ "Forest",
    leg_MAJOR_ == "FOREST TRANSITIONS AND MOSAICS" ~ "Forest mosaics",
    leg_MAJOR_ == "GRASSLAND" ~ "Grassland, shrubland",
    leg_MAJOR_ == "GRASSY SHRUBLAND" ~ "Grassland, shrubland",
    leg_MAJOR_ == "SECONDARY WOODED GRASSLAND" ~ "Woodland",
    leg_MAJOR_ == "SEMI-DESERT VEGETATION" ~ "Desert, semi-desert",
    leg_MAJOR_ == "TRANSITIONAL SCRUBLAND" ~ "Grassland, shrubland",
    leg_MAJOR_ == "WOODLAND" ~ "Woodland",
    leg_MAJOR_ == "WOODLAND MOSAICS AND TRANSITIONS" ~ "Woodland mosaics",
    TRUE ~ NA_character_)) %>%
  group_by(leg_MAJOR_) %>%
  summarise()

saf_map <- ggplot() + 
  geom_sf(data = white_crop[!white_crop$leg_MAJOR_ %in% 
    c("Bushland, thicket", "Forest mosaics", 
      "Grassland, shrubland", "Woodland", "Woodland mosaics"),],
    fill = "#999999") + 
  geom_sf(data = white_crop[white_crop$leg_MAJOR_ %in% 
    c("Bushland, thicket", "Forest mosaics", 
      "Grassland, shrubland", "Woodland", "Woodland mosaics"),], 
    aes(fill = leg_MAJOR_), colour = NA) + 
  geom_sf(data = saf, fill = NA, colour = "black") + 
  scale_fill_manual(name = "", values = c("#b58900", "#117733", "#9fde8a", 
      "#55A868", "#66a61e")) + 
  theme_bw() + 
  labs(x = "", y = "")

pdf(file = "img/saf_map.pdf", width = 8, height = 8)
saf_map
dev.off()

# Crop TEOW to tropics
teow_fil <- teow %>% 
  filter(REALM == "Afrotropic") %>%
  st_make_valid() 

africa_bbox_poly <- st_as_sfc(africa_bbox)

teow_crop <- st_crop(teow_fil, africa_bbox_poly) %>%
  filter(ECO_NAME %in% c(
      "Angolan mopane woodlands", 
      "Angolan wet miombo woodlands",
      "Central Zambezian wet miombo woodlands",
      "Zambezian Baikiaea woodlands",
      "Dry miombo woodlands",
      "Zambezian mopane woodlands")) %>%
  mutate(veg_type = case_when(
      ECO_NAME == "Angolan mopane woodlands" ~ "Mopane", 
      ECO_NAME == "Angolan wet miombo woodlands" ~ "Miombo",
      ECO_NAME == "Central Zambezian wet miombo woodlands" ~ "Miombo",
      ECO_NAME == "Zambezian Baikiaea woodlands" ~ "Baikiaea",
      ECO_NAME == "Dry miombo woodlands" ~ "Miombo",
      ECO_NAME == "Zambezian mopane woodlands" ~ "Mopane")) %>%
  group_by(veg_type) %>% 
  summarise() %>%
  st_simplify(., dTolerance = 0.05)

teow_map <- ggplot() + 
  geom_sf(data = saf, fill = "lightgrey", colour = NA) + 
  geom_sf(data = teow_crop, aes(fill = veg_type), colour = NA) + 
  geom_sf(data = saf, fill = NA, colour = "black") + 
  theme_bw() + 
  scale_fill_manual(name = "", values = c("#20dfa3", "#4420df", "#d95f02"))

pdf(file = "img/saf_teow.pdf", width = 8, height = 8)
teow_map
dev.off()


pdf(file = "img/saf_map_both.pdf", width = 10, height = 5.5)
saf_map + teow_map + 
  plot_layout(guides = "collect")
dev.off()
