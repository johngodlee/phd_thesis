# Create maps of SEOSAW plots, Bicuar highlighted, spatial, climate, disturbance, human
# John Godlee (johngodlee@gmail.com)
# 2021-05-17

# Packages
library(ggplot2)
library(dplyr)
library(nngeo)
library(smoothr)
library(rgeos)
library(sf)
library(rnaturalearth)
library(seosawr)
library(scico)
library(ggnewscale)
library(raster)
library(scales)
library(patchwork)

# Import data
plots <- st_read("dat/points/points.shp")

plots_spatial <- read.csv("dat/plots_spatial.csv")

africa <- ne_countries(scale = "medium", returnclass = "sf") %>%
  filter(continent == "Africa")

data(seosaw_region)

bioclim <- stack("/Volumes/seosaw_spat/wc2.1_30s_bio/bioclim.vrt")

herbivory <- stack("/Volumes/seosaw_spat/herbivory/historic.gri")

fire_count <- raster("/Volumes/seosaw_spat/fire/AFcount_2001_2018.tif")

travel_time <- raster("/Volumes/seosaw_spat/malaria_atlas/2015_accessibility_to_cities_v1.0.tif")

pop_density <- raster("/Volumes/seosaw_spat/worldpop/ppp_2020_1km_Aggregated.tif")

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
saf <- st_crop(africa, africa_bbox)

# Crop seosaw region to bbox 
seosaw_region_crop <- st_crop(seosaw_region, saf)

# Get permanent plots only, bin n censuses
psp <- plots %>%
  filter(permanent == 1) %>%
  mutate(bicuar = ifelse(grepl("ABG", plot_id), "Bicuar", "Other")) %>%
  cbind(., st_coordinates(.))

# Get one-off plots only
oop <- plots %>% 
  filter(permanent == 0) %>%
  cbind(., st_coordinates(.))

# Are all plots included in only one of above dataframes
stopifnot(nrow(plots) == nrow(psp) + nrow(oop))

# Construct plot
plot_map <- ggplot() + 
  geom_sf(data = saf, colour = NA, fill = "lightgray") + 
  geom_sf(data = seosaw_region_crop, colour = "thistle4", 
    fill = "thistle1", alpha = 0.9) + 
  geom_sf(data = saf, colour = "black", fill = NA) + 
  geom_hex(data = oop, 
    aes(x = X, y = Y),
    bins = 30) +
  scale_fill_scico(name = "One-off plots,\nN plots", palette = "bamako") + 
  new_scale_fill() +
  geom_point(data = psp, aes(x = X, y = Y, fill = bicuar, size = bicuar),
    shape = 21, colour = "black",
    position = position_jitter(width = 0.2, height = 0.2)) + 
  scale_fill_manual(name = "", values = c("#E15759", "#8ac3ff")) + 
  scale_size_manual(name = "", values = c(6, 4)) + 
  theme_bw() + 
  labs(x = "", y = "") + 
  theme(legend.position = c(0.9, 0.2),
    legend.background = element_rect(fill =alpha("white", 0)),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 12))

# Save image
pdf(file = "img/seosaw_plots.pdf", width = 8, height = 8)
plot_map
dev.off()

# Space plots

seosaw_sp <- as(seosaw_region, 'Spatial') 
seosaw_simp <- gSimplify(seosaw_sp, tol = 0.2)
seosaw_fill <- fill_holes(seosaw_simp, threshold = units::set_units(1000000, km^2))
seosaw_sf <- st_as_sf(seosaw_fill)

# Mask layers by SEOSAW region ----
bioclim_fil <- subset(bioclim, c("bioclim.1", "bioclim.12"))
bioclim_crop <- crop(bioclim_fil, seosaw_sf)
bioclim_mask <- mask(bioclim_crop, seosaw_sf)

herbivory_fil <- subset(herbivory, "Total")
herbivory_crop <- crop(herbivory_fil, seosaw_sf)
herbivory_mask <- mask(herbivory_crop, seosaw_sf)

fire_count_crop <- crop(fire_count, seosaw_sf)
fire_count_mask <- mask(fire_count_crop, seosaw_sf)

travel_time_crop <- crop(travel_time, seosaw_sf)
travel_time_mask <- mask(travel_time_crop, seosaw_sf)

pop_density_crop <- crop(pop_density, seosaw_sf)
pop_density_mask <- mask(pop_density_crop, seosaw_sf)

# Extract values from masked layers for 2D plots ----
# Climate
clim_df <- as.data.frame(values(bioclim_mask))
names(clim_df) <- c("mat", "map")

# Disturbance
herbivory_res <- resample(herbivory_mask, fire_count_mask)

disturbance_df <- data.frame(herbivory = values(herbivory_res), 
  fire_count = values(fire_count_mask))

# Humans
humans_df <- data.frame(travel_time = values(travel_time_mask),
  pop_density = values(pop_density_mask))

# Sort plot data so permanent and Bicuar on top
plots_spatial_sort <- plots_spatial %>%
  mutate(bicuar = case_when(
      grepl("ABG", plot_id) ~ "Bicuar",
      grepl(paste(unique(gsub("_.*", "", psp$plot_id)), collapse = "|"), plot_id) ~ "Permanent",
      TRUE ~ "One-off")) %>%
  mutate(bicuar = factor(bicuar, levels = c("Bicuar", "Permanent", "One-off"))) %>%
  arrange(desc(bicuar))

clim_plot <- ggplot() + 
  geom_bin2d(data = clim_df, 
    mapping = aes(x = mat, y = map, fill = ..count..), 
    bins = 100) +
  scale_fill_scico(name = "Pixel density", palette = "bamako", trans = "log", 
    breaks = c(1, 10, 100, 1000, 10000)) +
  new_scale_fill() + 
  geom_point(data = plots_spatial_sort, 
    aes(x = bio1, y = bio12, size = bicuar, shape = bicuar, colour = bicuar, 
      fill = bicuar)) + 
  scale_shape_manual(name = "", values = c(21, 21, 3)) + 
  scale_size_manual(name = "", values = c(4, 2, 1)) + 
  scale_fill_manual(name = "", values = c("#E15759", "#8ac3ff", "black")) + 
  scale_colour_manual(name = "", values = c("black", "black", "black")) + 
  theme_bw() + 
  labs(
    x = expression("MAT" ~ (degree*C)), 
    y = expression("MAP" ~ (mm ~ y^-1)))

disturbance_plot <- ggplot() + 
  geom_bin2d(data = disturbance_df, 
    mapping = aes(x = herbivory, y = fire_count, fill = ..count..), 
    bins = 25) +
  scale_fill_scico(name = "Pixel density", palette = "bamako", trans = "log", 
    breaks = c(1, 10, 100, 1000, 10000)) +
  new_scale_fill() + 
  geom_point(data = plots_spatial_sort, 
    aes(x = herbiv_total, y = fire_count, size = bicuar, shape = bicuar, colour = bicuar, 
      fill = bicuar)) + 
  scale_shape_manual(name = "", values = c(21, 21, 3)) + 
  scale_size_manual(name = "", values = c(4, 2, 1)) + 
  scale_fill_manual(name = "", values = c("#E15759", "#8ac3ff", "black")) + 
  scale_colour_manual(name = "", values = c("black", "black", "black")) + 
  theme_bw() + 
  labs(x = expression("Herbivore biomass" ~  (kg ~ km^-2)), 
    y = expression("Number of fires" ~ (2001-2018))) +
  ylim(0, 35)

humans_plot <- ggplot() + 
  geom_bin2d(data = humans_df[humans_df$travel_time > 0,], 
    mapping = aes(x = pop_density, y = travel_time, fill = ..count..), 
    bins = 25) +
  scale_fill_scico(name = "Pixel density", palette = "bamako", trans = "log", 
    breaks = c(1, 10, 100, 1000, 10000)) +
  new_scale_fill() + 
  geom_point(data = plots_spatial_sort,
    aes(x = pop_density, y = travel_time_city, size = bicuar, shape = bicuar, colour = bicuar, 
      fill = bicuar)) + 
  scale_shape_manual(name = "", values = c(21, 21, 3)) + 
  scale_size_manual(name = "", values = c(4, 2, 1)) + 
  scale_fill_manual(name = "", values = c("#E15759", "#8ac3ff", "black")) + 
  scale_colour_manual(name = "", values = c("black", "black", "black")) + 
  scale_x_continuous(trans='log2') + 
  scale_y_continuous(trans='log2') + 
  theme_bw() + 
  labs(x = expression("Human population" ~ km^-2), 
    y = expression("Travel time to nearest city" ~ (min))) 

pdf(file = "img/seosaw_clim.pdf", width = 7.5, height = 6)
clim_plot
dev.off()

pdf(file = "img/seosaw_disturbance.pdf", width = 7.5, height = 6)
disturbance_plot
dev.off()

pdf(file = "img/seosaw_humans.pdf", width = 7.5, height = 6)
humans_plot
dev.off()

pdf(file = "img/seosaw_space_all.pdf", width = 14, height = 5)
(clim_plot + disturbance_plot + humans_plot) + 
  plot_layout(guides = "collect") &
  theme(legend.position = "none")
dev.off()
