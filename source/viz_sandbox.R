
library(tidyr)
library(dplyr)
library(ggplot2)
library(ggridges)

load("results/all_distances.rda")

all_distances <- pivot_longer(all_distances, cols = BingSingle:HereBatch, names_to = "geocoder", values_to = "error")

all_distances %>%
  group_by(geocoder) %>%
  summarise(
    mean_diff = mean(error, na.rm = TRUE),
    median_diff = median(error, na.rm = TRUE),
    min_diff = min(error, na.rm = TRUE),
    max_diff = max(error, na.rm = TRUE)
  )

all_distances %>%
  filter(error < 75) %>%
  # filter(geocoder %in% c("BingBatch", "BingSingle") == FALSE) %>%
  ggplot() +
    geom_violin(aes(x = geocoder, y = error))
