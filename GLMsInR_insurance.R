# --- PREAMBLE ---
options(repos = c(CRAN = "https://cloud.r-project.org")) # CRAN mirror

install.packages("tidyverse", dependencies = TRUE)
install.packages("sjPlot", dependencies = TRUE)
install.packages("lme4", dependencies = TRUE)
install.packages("tweedie", dependencies = TRUE)
install.packages("cowplot", dependencies = TRUE)
install.packages("statmod", dependencies = TRUE) # install relevent packages

library(tidyverse)
library(sjPlot)
library(lme4)
library(tweedie)
library(cowplot)
library(statmod) # read in


# --- DATA AND GLM MODELS ---
d <- read.csv("insurance.csv")
d$sex    <- factor(d$sex)
d$smoker <- factor(d$smoker)
d$region <- factor(d$region)

head(d)

m <- glm(charges ~ ., family = tweedie(var.power = 1.67, link.power = 0), data = d)
m_base <- glm(charges ~ 1, family = tweedie(var.power = 1.67, link.power = 0), data = d)


# --- STATISTICS ---
#tab_model(m_base, m)
#summary(m_base, m)

anova(m_base, m, test="Chisq") # stats to find best model


# --- PLOTS ---
p_list <- sjPlot::plot_model(
  m,
  type = "pred",
  title = "",   # no individual titles   
  colors = "#ff00cc",
  ci.lvl = 0.95
)

grid <- cowplot::plot_grid(plotlist = p_list, ncol = 2) # plots in grid

title_grob <- cowplot::ggdraw() +
  cowplot::draw_label(
    "Predicted Medical Insurance Premiums using Tweedie GLM", # overall title
    fontface = "bold",
    x = 0.5, hjust = 0.5, vjust = 1, size = 14
  )

final_plot <- cowplot::plot_grid(title_grob, grid, ncol = 1, rel_heights = c(0.08, 1)) # title above grid

ggsave("insurance_glm_plots.pdf", plot = final_plot) #save plots as pdf


