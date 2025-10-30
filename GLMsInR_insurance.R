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

d$region <- dplyr::recode(
  d$region,
  "southeast" = "SE",
  "southwest" = "SW",
  "northeast" = "NE",
  "northwest" = "NW"
)

head(d)

# full-data models (kept for comparison / plots)
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

# accuracy/ error metrics
rmse <- sqrt(mean((pred - test$charges)^2))
mae  <- mean(abs(pred - test$charges))

cat("Accuracy metrics(Tweedie GLM)\n")
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
ggsave("predictedVSactualPremiums.png", plot = p_scatter)


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

ggsave("insurance_glm_plots.png", plot = final_plot) # save plots as png


# --- IMPROVE MODEL ---

options(contrasts = c("contr.treatment", "contr.poly")) # deals with categorical vars

formula_imp <- charges ~ smoker * age + smoker * bmi + I(bmi^2) + children + sex + region # introduce interactions in model


p_grid <- seq(1.3, 1.9, by = 0.05) # try different p values

best_p <- NA_real_ # empty var to store best p val


prof_try <- try(
  tweedie::tweedie.profile(
    formula = formula_imp, # tests model with different p vals
    p.vec   = p_grid,
    data    = train,
    method  = "series",
    do.plot = FALSE
  ),
  silent = TRUE
)

# checks for no errors in prof try
if (!inherits(prof_try, "try-error") && is.list(prof_try) && !is.null(prof_try$p.max)) {
  best_p <- as.numeric(prof_try$p.max)
} else {
  rmse_by_p <- sapply(p_grid, function(p) { # standard grid search if above fails
    m_tmp <- glm(formula_imp, family = tweedie(var.power = p, link.power = 0), data = train)
    pred_tmp <- predict(m_tmp, newdata = test, type = "response")
    sqrt(mean((pred_tmp - test$charges)^2))
  })
  best_p <- p_grid[which.min(rmse_by_p)]
}

m_best <- glm( # fits model
  formula_imp,
  family = tweedie(var.power = best_p, link.power = 0),  # log link
  data   = train
)


pred_best <- predict(m_best, newdata = test, type = "response")
rmse_best <- sqrt(mean((pred_best - test$charges)^2))
mae_best  <- mean(abs(pred_best - test$charges)) # accuracy of new model

cat("\n[Improved Tweedie GLM]\n",
    "p:", round(best_p, 3),
    " | RMSE:", round(rmse_best, 3),
    " | MAE:", round(mae_best, 3), "\n")

# --- PLOT C ---

results_best <- data.frame(actual = test$charges, predicted = pred_best)

p_scatter_best <- ggplot(results_best, aes(x = actual, y = predicted)) +
  geom_point(alpha = 0.5, colour = "#f00909") +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "#000000") +
  labs(
    title = paste0("Improved Predicted VS Actual (Tweedie GLM, p = ", round(best_p, 3), ")"),
    x = "Actual Charges",
    y = "Predicted Charges"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.8)
  )

ggsave("improved_predictedVSactualPremiums.png",
       plot = p_scatter_best, width = 7, height = 5, units = "in")


# --- PLOT A with C (synchronized y-axis) ---

# find global y range across both models
y_min <- min(c(results$predicted, results_best$predicted))
y_max <- max(c(results$predicted, results_best$predicted))

# optionally extend a little for padding
y_pad <- 0.05 * (y_max - y_min)
y_limits <- c(y_min - y_pad, y_max + y_pad)

p_left_annotated <- p_scatter +
  coord_cartesian(ylim = y_limits) +  # fix same y range
  labs(title = NULL) +
  annotate("text",
           x = Inf, y = -Inf,
           label = paste0("RMSE = ", round(rmse, 1),
                          "\nMAE  = ", round(mae, 1),
                          "\np = 1.67"),
           hjust = 1.1, vjust = -0.5, size = 3.8,
           colour = "#333333", fontface = "bold") +
  theme(plot.margin = margin(10, 20, 10, 10))

p_right_annotated <- p_scatter_best +
  coord_cartesian(ylim = y_limits) +  # apply same range
  labs(title = NULL) +
  annotate("text",
           x = Inf, y = -Inf,
           label = paste0("RMSE = ", round(rmse_best, 1),
                          "\nMAE  = ", round(mae_best, 1),
                          "\np = ", round(best_p, 3)),
           hjust = 1.1, vjust = -0.5, size = 3.8,
           colour = "#333333", fontface = "bold") +
  theme(plot.margin = margin(10, 20, 10, 10))

comparison_annotated <- cowplot::plot_grid(
  p_left_annotated, p_right_annotated,
  labels = NULL,
  ncol = 2,
  align = "hv",
  rel_widths = c(1, 1)
)

ggsave("baseline_vs_improved_clean.png",
       plot = comparison_annotated,
       width = 12, height = 5, units = "in")