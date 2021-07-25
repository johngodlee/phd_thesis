# Niche overlap histograms
# John Godlee (johngodlee@gmail.com)
# 2021-05-26

# Packages
library(ggplot2)
library(patchwork)

# Create data for niche space

niche_space <- function(x) {
  data.frame(
    x = seq(-6,6,length.out = 14), 
    y = c(
      seq(0, x, length.out = 6), 
      rep(x, times = 2), 
      seq(x, 0, length.out = 6)))
}

# Niche overlap
p1_niche_space <- niche_space(0.45)
p1 <- ggplot(data = data.frame(x = c(-5, 5)), aes(x)) + 
  geom_line(data = p1_niche_space, aes(x = x, y = y), 
    linetype = 2) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = -1, sd = 1), 
    geom = "area", fill = "#377eb8", alpha = 0.5) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = -1, sd = 1), 
    geom = "line") + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = 1, sd = 1), 
    geom = "area", fill = "#df205c", alpha = 0.5) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = 1, sd = 1), 
    geom = "line") + 
  ggtitle("a")

p2 <- ggplot(data = data.frame(x = c(-5, 5)), aes(x)) +
  geom_line(data = p1_niche_space, aes(x = x, y = y), 
    linetype = 2) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = -0.2, sd = 1), 
    geom = "area", fill = "#377eb8", alpha = 0.5) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = -0.2, sd = 1), 
    geom = "line") + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = 0.2, sd = 1), 
    geom = "area", fill = "#df205c", alpha = 0.5) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = 0.2, sd = 1), 
    geom = "line")

pdf(file = "img/niche_overlap.pdf", width = 8, height = 2)
p1 + p2 & 
  labs(x = "Niche space", y = "Productivity") &
  theme_classic() &
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank())
dev.off()

# N species
p3 <- ggplot(data = data.frame(x = c(-5, 5)), aes(x)) + 
  geom_line(data = p1_niche_space, aes(x = x, y = y), 
    linetype = 2) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = -1.5, sd = 1), 
    geom = "area", fill = "#377eb8", alpha = 0.5) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = -1.5, sd = 1), 
    geom = "line") + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = 1.5, sd = 1), 
    geom = "area", fill = "#df205c", alpha = 0.5) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = 1.5, sd = 1), 
    geom = "line") + 
  ggtitle("b")

p4 <- ggplot(data = data.frame(x = c(-5, 5)), aes(x)) + 
  geom_line(data = p1_niche_space, aes(x = x, y = y), 
    linetype = 2) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = -1.5, sd = 1), 
    geom = "area", fill = "#377eb8", alpha = 0.5) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = -1.5, sd = 1), 
    geom = "line") + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = 1.5, sd = 1), 
    geom = "area", fill = "#55A868", alpha = 0.5) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = 1.5, sd = 1), 
    geom = "line") +
  stat_function(fun = dnorm, n = 1000, args = list(mean = 0, sd = 1), 
    geom = "area", fill = "#df205c", alpha = 0.5) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = 0, sd = 1), 
    geom = "line") 

pdf(file = "img/niche_species.pdf", width = 8, height = 2)
p3 + p4 & 
  labs(x = "Niche space", y = "Productivity") &
  theme_classic() &
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank())
dev.off()

# Niche breadth
p5_niche_space <- niche_space(0.5)
p5 <- ggplot(data = data.frame(x = c(-5, 5)), aes(x)) + 
  geom_line(data = p5_niche_space, aes(x = x, y = y), 
    linetype = 2) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = -1.5, sd = 1.5), 
    geom = "area", fill = "#377eb8", alpha = 0.5) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = -1.5, sd = 1.5), 
    geom = "line") + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = 1.5, sd = 1.5), 
    geom = "area", fill = "#55A868", alpha = 0.5) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = 1.5, sd = 1.5), 
    geom = "line") +
  stat_function(fun = dnorm, n = 1000, args = list(mean = 0, sd = 1.5), 
    geom = "area", fill = "#df205c", alpha = 0.5) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = 0, sd = 1.5), 
    geom = "line") + 
  ggtitle("c")

p6_niche_space <- niche_space(1.1)
p6 <- ggplot(data = data.frame(x = c(-5, 5)), aes(x)) + 
  geom_line(data = p6_niche_space, aes(x = x, y = y), 
    linetype = 2) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = -1.5, sd = 0.4), 
    geom = "area", fill = "#377eb8", alpha = 0.5) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = -1.5, sd = 0.4), 
    geom = "line") + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = 1.5, sd = 0.4), 
    geom = "area", fill = "#55A868", alpha = 0.5) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = 1.5, sd = 0.4), 
    geom = "line") +
  stat_function(fun = dnorm, n = 1000, args = list(mean = 0, sd = 0.4), 
    geom = "area", fill = "#df205c", alpha = 0.5) + 
  stat_function(fun = dnorm, n = 1000, args = list(mean = 0, sd = 0.4), 
    geom = "line") 

pdf(file = "img/niche_breadth.pdf", width = 8, height = 2)
p4 + p6 & 
  labs(x = "Niche space", y = "Productivity") &
  theme_classic() &
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank())
dev.off()

pdf(file = "img/niche_all.pdf", width = 8, height = 6)
(p1 + p2) / (p3 + p4) / (p5 + p6) & 
  labs(x = "Niche space", y = "Productivity") &
  theme_classic() &
  theme(
    plot.title = element_text(size = 20),
    axis.text = element_blank(),
    axis.ticks = element_blank())
dev.off()
