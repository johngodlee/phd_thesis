# Create maps of SEOSAW plots, Bicuar highlighted, spatial and climate 
# John Godlee (johngodlee@gmail.com)
# 2021-04-25

# Packages
library(ggplot2)
library(dplyr)
library(sf)
library(rnaturalearth)
library(seosawr)
library(scico)
library(ggnewscale)
library(raster)
library(scales)

# Import data
plots <- st_read("dat/points/points.shp")

plots_spatial <- read.csv("dat/plots_spatial.csv")

africa <- ne_countries(scale = "medium", returnclass = "sf") %>%
  filter(continent == "Africa")

data(seosaw_region)

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

# Climate plot

# Extract WorldClim values for every pixel in SEOSAW region
tavg_files <- list.files("/Volumes/john/worldclim/wc2.1_5m_tavg", "*.tif", 
  full.names = TRUE)

tavg <- raster::stack(tavg_files)

tavg_crop <- crop(tavg, seosaw_region_crop)

tavg_mean <- calc(tavg_crop, mean)

tavg_mask <- mask(tavg_mean, seosaw_region_crop)

prec_files <- list.files("/Volumes/john/worldclim/wc2.1_5m_prec", "*.tif", 
  full.names = TRUE)

prec <- raster::stack(prec_files)

prec_crop <- crop(prec, seosaw_region_crop)

prec_sum <- calc(prec_crop, sum)

prec_mask <- mask(prec_sum, seosaw_region_crop)

seosaw_region_clim <- data.frame(
  mat = values(tavg_mask),
  map = values(prec_mask)) %>%
  filter(!is.na(mat), !is.na(map))

# Classify plots
plots_spatial_sort <- plots_spatial %>%
  mutate(bicuar = case_when(
      grepl("ABG", plot_id) ~ "Bicuar",
      grepl(paste(unique(gsub("_.*", "", psp$plot_id)), collapse = "|"), plot_id) ~ "Permanent",
      TRUE ~ "One-off")) %>%
  mutate(bicuar = factor(bicuar, levels = c("Bicuar", "Permanent", "One-off"))) %>%
  arrange(desc(bicuar))

# Create plot
clim_map <- ggplot() + 
  stat_density_2d(data = seosaw_region_clim, 
    aes(x = mat, y = map, fill = ..density..), 
    geom = "raster", contour = FALSE) +
  scale_fill_scico(name = "Pixel density", palette = "bamako") + 
  new_scale_fill() + 
  geom_point(data = plots_spatial_sort, 
    aes(x = bio1, y = bio12, size = bicuar, shape = bicuar, colour = bicuar, 
      fill = bicuar)) + 
  scale_shape_manual(name = "", values = c(21, 21, 3)) + 
  scale_size_manual(name = "", values = c(4, 2, 1)) + 
  scale_fill_manual(name = "", values = c("#E15759", "#8ac3ff", "black")) + 
  scale_colour_manual(name = "", values = c("black", "black", "black")) + 
  theme_bw() + 
  lims(
    x = range(plots_spatial_sort$bio1) + c(-1,1), 
    y = range(plots_spatial_sort$bio12) + c(-100,100)) + 
  labs(
    x = expression("MAT" ~ (degree*C)), 
    y = expression("MAP" ~ (mm ~ y^-1)))

# Save image
pdf(file = "img/seosaw_clim.pdf", width = 7.5, height = 6)
clim_map
dev.off()

