# ============================================================
# NCAA Tournament Upset Prediction
# Script 04: Predictive Modeling
#
# Research Question:
# Which regular-season team statistics are most useful for
# predicting upsets in the NCAA Men's Basketball Tournament?
#
# Purpose:
# Use logistic regression to test whether regular-season
# statistics predict upsets better than tournament seeds alone.
#
# Training seasons: 2003-2019
# Testing seasons:  2021-2025
#
# All modeling decisions use the training seasons only. The
# testing seasons are used once, for the final comparison.
# ============================================================


# ------------------------------------------------------------
# 1. LOAD PACKAGES
# ------------------------------------------------------------

library(tidyverse)


# ------------------------------------------------------------
# 2. IMPORT TOURNAMENT MATCHUP DATA
# ------------------------------------------------------------

upset_data <- read_csv(
  "data/tournament_upset_data.csv",
  show_col_types = FALSE
)


# ------------------------------------------------------------
# 3. SPLIT THE DATA BY SEASON
# ------------------------------------------------------------

# Splitting by season means the model is always tested on
# tournaments that happened after the ones it learned from.
#
# There was no 2020 tournament.

train_data <- upset_data %>%
  filter(Season <= 2019)

test_data <- upset_data %>%
  filter(Season >= 2021)


# Check the size and upset rate of each group.

split_summary <- bind_rows(
  Training = train_data,
  Testing = test_data,
  .id = "Group"
) %>%
  group_by(Group) %>%
  summarise(
    FirstSeason = min(Season),
    LastSeason = max(Season),
    Games = n(),
    Upsets = sum(Upset),
    UpsetRate = mean(Upset),
    .groups = "drop"
  )

print(split_summary)


# ------------------------------------------------------------
# 4. DEFINE THE PREDICTORS
# ------------------------------------------------------------

# Point margin equals points scored minus points allowed, so
# AvgPointsDifference and AvgPointsAllowedDifference cannot be
# included alongside PointMarginDifference.

seed_predictor <- "SeedDifference"

stat_predictors <- c(
  "WinPctDifference",
  "PointMarginDifference",
  "SOSDifference",
  "FGPercentDifference",
  "ThreePPercentDifference",
  "FTPercentDifference",
  "ReboundDifference",
  "AssistDifference",
  "TurnoverDifference",
  "StealDifference",
  "BlockDifference"
)

full_predictors <- c(
  seed_predictor,
  stat_predictors
)


# ------------------------------------------------------------
# 5. CREATE HELPER FUNCTIONS
# ------------------------------------------------------------

# Build a model formula from a list of predictors.
# An empty list creates an intercept-only model.

make_formula <- function(predictors) {
  
  right_side <- if (length(predictors) == 0) {
    "1"
  } else {
    paste(predictors, collapse = " + ")
  }
  
  as.formula(
    paste("Upset ~", right_side)
  )
}


# Fit a logistic regression model.

fit_logistic <- function(predictors, data) {
  
  # do.call stores the data inside the model, which step()
  # needs when it refits the model in Section 7.
  do.call(
    "glm",
    list(
      formula = make_formula(predictors),
      data = data,
      family = binomial
    )
  )
}


# Log loss: lower is better. Confident wrong predictions are
# penalized heavily.

log_loss <- function(actual, predicted) {
  
  predicted <- pmin(pmax(predicted, 1e-15), 1 - 1e-15)
  
  -mean(
    actual * log(predicted) +
      (1 - actual) * log(1 - predicted)
  )
}


# Brier score: mean squared error of the probabilities.
# Lower is better.

brier_score <- function(actual, predicted) {
  
  mean((predicted - actual)^2)
}


# AUC: the chance that a randomly chosen upset receives a
# higher predicted probability than a randomly chosen
# non-upset. 0.5 is no better than guessing.

calculate_auc <- function(actual, predicted) {
  
  if (length(unique(predicted)) == 1) {
    return(0.5)
  }
  
  ranks <- rank(predicted)
  n_upsets <- sum(actual == 1)
  n_other <- sum(actual == 0)
  
  (sum(ranks[actual == 1]) -
      n_upsets * (n_upsets + 1) / 2) /
    (n_upsets * n_other)
}


# Variance inflation factor (VIF): how much each predictor is
# explained by the other predictors.

calculate_vif <- function(predictors, data) {
  
  map_dbl(
    predictors,
    function(predictor) {
      
      others <- setdiff(predictors, predictor)
      
      r_squared <- summary(
        lm(
          as.formula(
            paste(
              predictor,
              "~",
              paste(others, collapse = " + ")
            )
          ),
          data = data
        )
      )$r.squared
      
      1 / (1 - r_squared)
    }
  ) %>%
    set_names(predictors)
}


# ------------------------------------------------------------
# 6. CHECK MULTICOLLINEARITY
# ------------------------------------------------------------

# A common rule of thumb treats values above 5 as a concern.

vif_values <- calculate_vif(
  full_predictors,
  train_data
)

vif_table <- tibble(
  Predictor = names(vif_values),
  VIF = vif_values
) %>%
  arrange(desc(VIF))

print(vif_table)


# ------------------------------------------------------------
# 7. FIT THE MODELS ON THE TRAINING SEASONS
# ------------------------------------------------------------

# Base Rate:  predicts the same upset chance for every game.
# Seed Only:  the baseline model to beat.
# Full:       seed difference plus all regular-season stats.

base_rate_model <- fit_logistic(
  character(0),
  train_data
)

seed_model <- fit_logistic(
  seed_predictor,
  train_data
)

full_model <- fit_logistic(
  full_predictors,
  train_data
)


# Reduced: backward selection using AIC. Seed difference is
# always kept so the model measures what the statistics add
# beyond seeding.

reduced_model <- step(
  full_model,
  scope = list(
    lower = make_formula(seed_predictor),
    upper = make_formula(full_predictors)
  ),
  direction = "backward",
  trace = 0
)

reduced_predictors <- attr(
  terms(reduced_model),
  "term.labels"
)

cat("\nReduced model predictors:\n")
print(reduced_predictors)


# Likelihood-ratio test: do the added statistics improve the
# fit on the training seasons?

training_fit_test <- anova(
  seed_model,
  reduced_model,
  test = "Chisq"
)

print(training_fit_test)


# ------------------------------------------------------------
# 8. CROSS-VALIDATE ON THE TRAINING SEASONS
# ------------------------------------------------------------

# Hold out one training season at a time. This is used to pick
# between the Full and Reduced models without touching the
# testing seasons.
#
# The Reduced model's predictors are chosen again inside every
# fold so the held-out season does not influence the selection.

fit_reduced <- function(data) {
  
  step(
    fit_logistic(full_predictors, data),
    scope = list(
      lower = make_formula(seed_predictor),
      upper = make_formula(full_predictors)
    ),
    direction = "backward",
    trace = 0
  )
}

training_seasons <- sort(unique(train_data$Season))

cv_predictions <- map_dfr(
  training_seasons,
  function(held_out_season) {
    
    fold_train <- train_data %>%
      filter(Season != held_out_season)
    
    fold_test <- train_data %>%
      filter(Season == held_out_season)
    
    fold_models <- list(
      "Base Rate" = fit_logistic(character(0), fold_train),
      "Seed Only" = fit_logistic(seed_predictor, fold_train),
      "Full" = fit_logistic(full_predictors, fold_train),
      "Reduced" = fit_reduced(fold_train)
    )
    
    imap_dfr(
      fold_models,
      function(model, model_name) {
        tibble(
          Model = model_name,
          Season = held_out_season,
          Upset = fold_test$Upset,
          Predicted = predict(
            model,
            newdata = fold_test,
            type = "response"
          )
        )
      }
    )
  }
)

cv_results <- cv_predictions %>%
  group_by(Model) %>%
  summarise(
    CV_LogLoss = log_loss(Upset, Predicted),
    CV_Brier = brier_score(Upset, Predicted),
    CV_AUC = calculate_auc(Upset, Predicted),
    .groups = "drop"
  ) %>%
  mutate(
    # The Base Rate model cannot rank games, so its AUC is 0.5.
    # Its prediction only changes between held-out seasons.
    CV_AUC = if_else(Model == "Base Rate", 0.5, CV_AUC)
  ) %>%
  arrange(CV_LogLoss)

print(cv_results)


# Select the statistics model with the lower cross-validated
# log loss.

selected_model_name <- cv_results %>%
  filter(Model %in% c("Full", "Reduced")) %>%
  slice_min(CV_LogLoss, n = 1, with_ties = FALSE) %>%
  pull(Model)

selected_model <- if (selected_model_name == "Full") {
  full_model
} else {
  reduced_model
}

selected_predictors <- attr(
  terms(selected_model),
  "term.labels"
)

cat("\nSelected statistics model:", selected_model_name, "\n")


# ------------------------------------------------------------
# 9. EVALUATE THE MODELS ON THE TESTING SEASONS
# ------------------------------------------------------------

final_models <- list(
  "Base Rate" = base_rate_model,
  "Seed Only" = seed_model,
  "Full" = full_model,
  "Reduced" = reduced_model
)

test_predictions <- imap_dfr(
  final_models,
  function(model, model_name) {
    tibble(
      Model = model_name,
      Season = test_data$Season,
      FavoriteTeam = test_data$FavoriteTeam,
      UnderdogTeam = test_data$UnderdogTeam,
      FavoriteSeed = test_data$FavoriteSeed,
      UnderdogSeed = test_data$UnderdogSeed,
      Upset = test_data$Upset,
      Predicted = predict(
        model,
        newdata = test_data,
        type = "response"
      )
    )
  }
)

test_results <- test_predictions %>%
  group_by(Model) %>%
  summarise(
    Test_LogLoss = log_loss(Upset, Predicted),
    Test_Brier = brier_score(Upset, Predicted),
    Test_AUC = calculate_auc(Upset, Predicted),
    Test_Accuracy = mean((Predicted >= 0.5) == (Upset == 1)),
    .groups = "drop"
  )

model_comparison <- cv_results %>%
  left_join(test_results, by = "Model") %>%
  mutate(
    Selected = Model == selected_model_name
  ) %>%
  arrange(Test_LogLoss)

print(model_comparison, width = Inf)


# ------------------------------------------------------------
# 10. MEASURE UNCERTAINTY IN THE IMPROVEMENT
# ------------------------------------------------------------

# Resample the testing games to estimate how much the log-loss
# improvement could vary.
#
# Improvement = Seed Only log loss - Selected model log loss
# Positive values favor the selected model.

set.seed(484)

seed_probs <- predict(
  seed_model,
  newdata = test_data,
  type = "response"
)

selected_probs <- predict(
  selected_model,
  newdata = test_data,
  type = "response"
)

bootstrap_improvement <- map_dbl(
  1:5000,
  function(i) {
    
    rows <- sample(
      nrow(test_data),
      replace = TRUE
    )
    
    log_loss(test_data$Upset[rows], seed_probs[rows]) -
      log_loss(test_data$Upset[rows], selected_probs[rows])
  }
)

improvement_summary <- tibble(
  Comparison = paste(selected_model_name, "vs Seed Only"),
  LogLossImprovement =
    log_loss(test_data$Upset, seed_probs) -
    log_loss(test_data$Upset, selected_probs),
  Lower95 = unname(quantile(bootstrap_improvement, 0.025)),
  Upper95 = unname(quantile(bootstrap_improvement, 0.975)),
  ShareOfResamplesImproved = mean(bootstrap_improvement > 0)
)

print(improvement_summary, width = Inf)


# ------------------------------------------------------------
# 11. INTERPRET THE SELECTED MODEL
# ------------------------------------------------------------

# Standardize each predictor using the training seasons. Each
# odds ratio then describes a one standard deviation increase,
# which makes the predictors comparable.
#
# Odds ratio above 1: upset becomes more likely
# Odds ratio below 1: upset becomes less likely

standardized_train <- train_data %>%
  mutate(
    across(
      all_of(selected_predictors),
      ~ as.numeric(scale(.x))
    )
  )

standardized_model <- fit_logistic(
  selected_predictors,
  standardized_train
)

coefficient_table <- summary(standardized_model)$coefficients

confidence_limits <- confint.default(standardized_model)

odds_ratios <- tibble(
  Predictor = rownames(coefficient_table),
  OddsRatioPerSD = exp(coefficient_table[, "Estimate"]),
  Lower95 = exp(confidence_limits[, 1]),
  Upper95 = exp(confidence_limits[, 2]),
  PValue = coefficient_table[, "Pr(>|z|)"]
) %>%
  filter(Predictor != "(Intercept)") %>%
  arrange(desc(abs(log(OddsRatioPerSD))))

print(odds_ratios, width = Inf)


# ------------------------------------------------------------
# 12. CREATE FIGURES
# ------------------------------------------------------------

dir.create(
  "figures",
  showWarnings = FALSE
)


# Odds ratios for the selected model.

odds_ratio_plot <- ggplot(
  odds_ratios,
  aes(
    x = OddsRatioPerSD,
    y = reorder(Predictor, OddsRatioPerSD)
  )
) +
  geom_vline(
    xintercept = 1,
    linetype = "dashed",
    color = "gray50"
  ) +
  geom_linerange(
    aes(xmin = Lower95, xmax = Upper95)
  ) +
  geom_point(size = 2.5) +
  scale_x_log10() +
  labs(
    title = "What Moves the Odds of an Upset",
    subtitle = paste(
      selected_model_name,
      "model, 2003-2019 training seasons"
    ),
    x = "Odds ratio per 1 SD increase (95% CI, log scale)",
    y = NULL
  ) +
  theme_minimal()

ggsave(
  "figures/odds_ratios.png",
  odds_ratio_plot,
  width = 8,
  height = 5,
  dpi = 300
)


# Calibration on the testing seasons: when a model gives a
# certain upset chance, how often do upsets actually happen?

calibration_data <- test_predictions %>%
  filter(Model %in% c("Seed Only", selected_model_name)) %>%
  group_by(Model) %>%
  mutate(
    Bin = ntile(Predicted, 5)
  ) %>%
  group_by(Model, Bin) %>%
  summarise(
    AveragePredicted = mean(Predicted),
    ActualUpsetRate = mean(Upset),
    Games = n(),
    .groups = "drop"
  )

calibration_plot <- ggplot(
  calibration_data,
  aes(
    x = AveragePredicted,
    y = ActualUpsetRate,
    color = Model
  )
) +
  geom_abline(
    slope = 1,
    intercept = 0,
    linetype = "dashed",
    color = "gray50"
  ) +
  geom_line() +
  geom_point(size = 2.5) +
  coord_equal(
    xlim = c(0, 0.65),
    ylim = c(0, 0.65)
  ) +
  labs(
    title = "Predicted vs. Actual Upset Rate",
    subtitle = "Testing seasons 2021-2025, five equal-sized groups",
    x = "Average predicted upset probability",
    y = "Actual upset rate"
  ) +
  theme_minimal()

ggsave(
  "figures/calibration.png",
  calibration_plot,
  width = 7,
  height = 6,
  dpi = 300
)


# ------------------------------------------------------------
# 13. EXPORT RESULTS
# ------------------------------------------------------------

write_csv(
  model_comparison,
  "data/model_comparison.csv"
)

write_csv(
  improvement_summary,
  "data/model_improvement.csv"
)

write_csv(
  odds_ratios,
  "data/model_odds_ratios.csv"
)

write_csv(
  vif_table,
  "data/model_vif.csv"
)

write_csv(
  test_predictions,
  "data/test_predictions.csv"
)
