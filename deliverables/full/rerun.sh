#!/usr/bin/env Rscript
require("ggplot2")
require("dplyr")

restarts <- read.csv("aggregated/actualTemperedRestarts.csv.gz")
restarts %>%
  filter(round == 8) %>%
  group_by(reversible, nChains) %>%
  summarise(mean_count = mean(count)) %>%
  ggplot(aes(x = nChains, y = mean_count, colour = reversible)) +
    scale_x_log10() +
    ylab("Average number of tempered restarts") + 
    geom_line()  + 
    theme_bw()
ggsave("restarts.pdf", width = 5, height = 5)
