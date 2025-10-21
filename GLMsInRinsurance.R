# --- PREAMBLE ---
options(repos = c(CRAN = "https://cloud.r-project.org")) # CRAN mirror

install.packages("tidyverse", dependencies = TRUE)
install.packages("sjPlot", dependencies = TRUE)
install.packages("lme4", dependencies = TRUE)
install.packages("cowplot", dependencies = TRUE) # install relevent packages

library(tidyverse)
library(sjPlot)
library(lme4)
library(cowplot) # read in


# --- DATA AND GLM ---
d <- mutate(iris, versicolor = as.numeric(Species == "versicolor"))
head(d)
m <- glm(versicolor ~ Sepal.Length + Sepal.Width, family = binomial, data = d) # two predictors # nolint: line_length_linter.

summary(m)
tab_model(m) # statistical info

# --- STATISTICS ---
dir.create("outputs", showWarnings = FALSE)
out_file <- file.path(getwd(), "outputs", "glm_versicolor.html")

tab_model(m, file = out_file)      # writes to disk
#file.exists(out_file) sanity check: should be TRUE



# --- OTHER MODELS ---
m_base <- glm(versicolor ~ 1, family = binomial, data = d)
m2 <- glm(versicolor ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width, family = binomial, data = d)

anova(m_base, m, m2, test="Chisq") # stats to find best model
tab_model(m_base, m, m2)


# --- PLOTS ---
p_list <- sjPlot::plot_model(
  m2,
  type = "pred",
  title = "",   # no individual titles   
  colors = "#ff00cc",
  ci.lvl = 0.95
)

grid <- cowplot::plot_grid(plotlist = p_list, ncol = 2) # plots in grid

title_grob <- cowplot::ggdraw() +
  cowplot::draw_label(
    "GLM Predicted Probabilities for Iris Versicolor", # overall title
    fontface = "bold",
    x = 0.5, hjust = 0.5, vjust = 1, size = 14
  )

final_plot <- cowplot::plot_grid(title_grob, grid, ncol = 1, rel_heights = c(0.08, 1)) # title above grid

ggsave("iris_glm_plots.pdf", plot = final_plot) #save plots as pdf


