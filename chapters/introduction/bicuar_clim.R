# Summarise Bicuar Climate data
# John Godlee (johngodlee@gmail.com)
# 2021-05-24

# http://www.sasscalweathernet.org/weatherstat_daily_AO_we.php?loggerid_crit=0000361101&yrmth_crit=2018-01

# Packages
library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)

# Import data
file_list <- list.files(pattern = "*.xls", path = "/Volumes/john/bicuar_sasscal_weather/daily_weather", full.names = TRUE)

dat_list <- lapply(file_list, function(x) {
  dat = read_excel(x)
  dat$file = basename(x)  # Add filename as column
  dat
})

# Clean data
dat <- do.call(rbind, lapply(dat_list, function(x) { 
  out <- x[-1, !grepl("^#", names(x))]
  out <- out[1:(nrow(out) -3),]
  names(out) <- c(
    "station",
    "date", 
    "avg_air_temp",
    "min_air_temp",
    "max_air_temp",
    "peak_air_temp",
    "precip",
    "avg_wind_speed",
    "avg_wind_direc",
    "max_wind_speed",
    "max_wind_speed_direc",
    "humidity",
    "soil_temp_10cm",
    "barom_pres",
    "soil_moist",
    "avg_sol_irrad",
    "sum_sol_irrad",
    "file")
  out[,3:15] <- sapply(out[,3:15], as.numeric)
  out$date <- as.Date(out$date, format = "%d %b %Y")
  return(out)
}))

# Create fancy labels for variables
facet_labs <- c(
  expression("Mean"~"air"~"temperature"~(degree~C)), 
  expression("Daily"~"precipitation"~"(mm)"), 
  expression("Mean"~"wind"~"speed"~(m~s^-1)))
names(facet_labs) <- c("avg_air_temp", "precip", "avg_wind_speed")

# Gather data and add labels
dat_gather <- dat %>% 
  dplyr::select(date, avg_air_temp, precip, avg_wind_speed) %>%
  filter(date < as.Date("2018-12-01")) %>%
  gather(key, value, -date) %>%
  mutate(facet_labs = factor(key, levels = unique(key), labels = facet_labs))

# Plot data
pdf(file = "img/bicuar_weather.pdf", width = 10, height = 8)
ggplot() + 
  geom_line(data = dat_gather, aes(x = date, y = value)) + 
  facet_wrap(~facet_labs, scales = "free", ncol = 1, labeller = "label_parsed") +  
  scale_x_date(date_labels = "%Y-%m", date_breaks = "3 months") + 
  theme_bw() + 
  labs(x = "", y = "")
dev.off()

# Date range
range(dat$date)
