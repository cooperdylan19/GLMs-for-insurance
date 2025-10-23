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
d$region <- factor(d$region) # numeric codes

head(d)

# Full-data models (kept for comparison / plots)
m      <- glm(charges ~ ., family = tweedie(var.power = 1.67, link.power = 0), data = d)
m_base <- glm(charges ~ 1, family = tweedie(var.power = 1.67, link.power = 0), data = d)

# --- STATISTICS ---
#tab_model(m_base, m)
#summary(m_base, m)
anova(m_base, m, test="Chisq") # stats to find best model


# --- TRAIN / TEST SPLIT & EVALUATION ---
set.seed(123)                                # reproducible split
n <- nrow(d)
idx <- sample(1:n, size = floor(0.8 * n))    # 80% train

train <- d[idx, ]
test  <- d[-idx, ]

# Train Tweedie GLM on training data
m_train <- glm(charges ~ ., family = tweedie(var.power = 1.67, link.power = 0), data = train)

# Predict on held-out test data (response scale)
pred <- predict(m_train, newdata = test, type = "response")

# Error metrics
rmse <- sqrt(mean((pred - test$charges)^2))
mae  <- mean(abs(pred - test$charges))

cat("Holdout performance (Tweedie GLM)\n")
cat("RMSE:", round(rmse, 3), "\n")
cat("MAE :", round(mae, 3), "\n")



# --- PLOT A ---
results <- data.frame(actual = test$charges, predicted = pred)

# define plot and store in object
p_scatter <- ggplot(results, aes(x = actual, y = predicted)) +
  geom_point(alpha = 0.5, colour = "#0c2fdc") +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "#000000") +
  labs(
    title = "Predicted vs Actual Insurance Premiums using Tweedie GLM",
    x = "Actual Charges",
    y = "Predicted Charges"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),       # centred title
    panel.grid.major = element_blank(),                          # remove gridlines
    panel.grid.minor = element_blank(),
    panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.8)  # box border
  )

# save only once (no on-screen plotting)
ggsave("outputs/predictedVSactualPremiums.pdf", plot = p_scatter)


# --- PLOT B ---
# Use the trained model for predictions in plots
p_list <- sjPlot::plot_model(
  m_train,
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

ggsave("insurance_glm_plots.pdf", plot = final_plot) # save plots as pdf



