# ============================================================
# NCAA Tournament Upset Prediction
# Script 03: Exploratory Data Analysis
#
# Research Question:
# Which regular-season team statistics are most useful for
# predicting upsets in the NCAA Men's Basketball Tournament?
#
# Purpose:
# Explore the tournament matchup dataset created in Script 02
# and compare upsets with non-upsets.
# ============================================================


# ------------------------------------------------------------
# 1. LOAD PACKAGES
# ------------------------------------------------------------

library(tidyverse)


# ------------------------------------------------------------
# 2. IMPORT TOURNAMENT MATCHUP DATA
# ------------------------------------------------------------

# Import the final dataset created in Script 02.
#
# Each row represents one NCAA Tournament matchup between
# a favorite and an underdog.

upset_data <- read_csv(
  "data/tournament_upset_data.csv"
)


# ------------------------------------------------------------
# 3. BASIC DATA CHECKS
# ------------------------------------------------------------

# View the dataset.
View(upset_data)


# Check the number of rows and columns.
dim(upset_data)


# Check the range of seasons included.
range(upset_data$Season)


# Check each variable for missing values.
colSums(
  is.na(upset_data)
)


# ------------------------------------------------------------
# 4. OVERALL UPSET FREQUENCY
# ------------------------------------------------------------

# Count the number of upsets and non-upsets.
#
# Upset = 0 means the favorite won.
# Upset = 1 means the underdog won.

table(
  upset_data$Upset
)


# Calculate the proportion of games that were
# upsets and non-upsets.

prop.table(
  table(upset_data$Upset)
)


# Create a cleaner summary table.

upset_summary <- upset_data %>%
  count(
    Upset
  ) %>%
  mutate(
    Percentage = n / sum(n) * 100
  )


# Display the summary.
upset_summary


# ------------------------------------------------------------
# 5. UPSET RATE BY SEED DIFFERENCE
# ------------------------------------------------------------

# Determine how frequently upsets occur at different
# differences between the favorite and underdog seeds.
#
# For example:
#
# SeedDifference = 1 means seeds are very close.
# SeedDifference = 10 means there is a much larger difference.

upsets_by_seed_difference <- upset_data %>%
  group_by(
    SeedDifference
  ) %>%
  summarise(
    
    # Number of games with this seed difference.
    Games = n(),
    
    # Number of those games that were upsets.
    Upsets = sum(Upset),
    
    # Percentage of those games that were upsets.
    UpsetRate = mean(Upset),
    
    .groups = "drop"
  )


# Display the results.
upsets_by_seed_difference


# ------------------------------------------------------------
# 6. GRAPH UPSET RATE BY SEED DIFFERENCE
# ------------------------------------------------------------

ggplot(
  upsets_by_seed_difference,
  aes(
    x = SeedDifference,
    y = UpsetRate
  )
) +
  
  geom_col() +
  
  labs(
    title = "NCAA Tournament Upset Rate by Seed Difference",
    x = "Seed Difference",
    y = "Upset Rate"
  ) +
  
  scale_y_continuous(
    labels = scales::percent
  ) +
  
  theme_minimal()


# ------------------------------------------------------------
# 7. COMPARE UPSETS AND NON-UPSETS
# ------------------------------------------------------------

# Calculate the average statistical difference for games
# where the favorite won and games where an upset occurred.
#
# Remember:
#
# Difference = Underdog - Favorite
#
# Positive values mean the underdog had the higher value.
# Negative values mean the favorite had the higher value.

upset_comparison <- upset_data %>%
  group_by(
    Upset
  ) %>%
  summarise(
    
    Games = n(),
    
    AvgSeedDifference =
      mean(
        SeedDifference,
        na.rm = TRUE
      ),
    
    AvgWinPctDifference =
      mean(
        WinPctDifference,
        na.rm = TRUE
      ),
    
    AvgPointsDifference =
      mean(
        AvgPointsDifference,
        na.rm = TRUE
      ),
    
    AvgPointsAllowedDifference =
      mean(
        AvgPointsAllowedDifference,
        na.rm = TRUE
      ),
    
    AvgPointMarginDifference =
      mean(
        PointMarginDifference,
        na.rm = TRUE
      ),
    
    AvgFGPercentDifference =
      mean(
        FGPercentDifference,
        na.rm = TRUE
      ),
    
    AvgThreePPercentDifference =
      mean(
        ThreePPercentDifference,
        na.rm = TRUE
      ),
    
    AvgFTPercentDifference =
      mean(
        FTPercentDifference,
        na.rm = TRUE
      ),
    
    AvgReboundDifference =
      mean(
        ReboundDifference,
        na.rm = TRUE
      ),
    
    AvgAssistDifference =
      mean(
        AssistDifference,
        na.rm = TRUE
      ),
    
    AvgTurnoverDifference =
      mean(
        TurnoverDifference,
        na.rm = TRUE
      ),
    
    AvgStealDifference =
      mean(
        StealDifference,
        na.rm = TRUE
      ),
    
    AvgBlockDifference =
      mean(
        BlockDifference,
        na.rm = TRUE
      ),
    
    AvgSOSDifference =
      mean(
        SOSDifference,
        na.rm = TRUE
      ),
    
    .groups = "drop"
  )


# Display the comparison.
upset_comparison


# ------------------------------------------------------------
# 8. STRENGTH OF SCHEDULE AND UPSETS
# ------------------------------------------------------------

# Compare SOS differences between upsets and non-upsets.
#
# Positive SOSDifference:
# The underdog played the stronger schedule.
#
# Negative SOSDifference:
# The favorite played the stronger schedule.

ggplot(
  upset_data,
  aes(
    x = factor(Upset),
    y = SOSDifference
  )
) +
  
  geom_boxplot() +
  
  labs(
    title = "Strength of Schedule Difference and Tournament Upsets",
    x = "Game Result",
    y = "SOS Difference (Underdog - Favorite)"
  ) +
  
  scale_x_discrete(
    labels = c(
      "Favorite Won",
      "Upset"
    )
  ) +
  
  theme_minimal()


# ------------------------------------------------------------
# 9. WIN PERCENTAGE AND UPSETS
# ------------------------------------------------------------

# Compare the regular-season winning percentage difference
# for upsets and non-upsets.

ggplot(
  upset_data,
  aes(
    x = factor(Upset),
    y = WinPctDifference
  )
) +
  
  geom_boxplot() +
  
  labs(
    title = "Regular-Season Win Percentage Difference",
    x = "Game Result",
    y = "Win Percentage Difference (Underdog - Favorite)"
  ) +
  
  scale_x_discrete(
    labels = c(
      "Favorite Won",
      "Upset"
    )
  ) +
  
  theme_minimal()


# ------------------------------------------------------------
# 10. POINT MARGIN AND UPSETS
# ------------------------------------------------------------

# Compare regular-season scoring margin differences.

ggplot(
  upset_data,
  aes(
    x = factor(Upset),
    y = PointMarginDifference
  )
) +
  
  geom_boxplot() +
  
  labs(
    title = "Regular-Season Point Margin Difference",
    x = "Game Result",
    y = "Point Margin Difference (Underdog - Favorite)"
  ) +
  
  scale_x_discrete(
    labels = c(
      "Favorite Won",
      "Upset"
    )
  ) +
  
  theme_minimal()


# ------------------------------------------------------------
# 11. THREE-POINT SHOOTING AND UPSETS
# ------------------------------------------------------------

# Compare regular-season three-point percentage differences.

ggplot(
  upset_data,
  aes(
    x = factor(Upset),
    y = ThreePPercentDifference
  )
) +
  
  geom_boxplot() +
  
  labs(
    title = "Three-Point Percentage Difference",
    x = "Game Result",
    y = "3-Point Percentage Difference (Underdog - Favorite)"
  ) +
  
  scale_x_discrete(
    labels = c(
      "Favorite Won",
      "Upset"
    )
  ) +
  
  theme_minimal()


# ------------------------------------------------------------
# 12. FIELD-GOAL SHOOTING AND UPSETS
# ------------------------------------------------------------

# Compare overall field-goal percentage differences.

ggplot(
  upset_data,
  aes(
    x = factor(Upset),
    y = FGPercentDifference
  )
) +
  
  geom_boxplot() +
  
  labs(
    title = "Field-Goal Percentage Difference",
    x = "Game Result",
    y = "FG Percentage Difference (Underdog - Favorite)"
  ) +
  
  scale_x_discrete(
    labels = c(
      "Favorite Won",
      "Upset"
    )
  ) +
  
  theme_minimal()


# ------------------------------------------------------------
# 13. CORRELATION BETWEEN PREDICTORS
# ------------------------------------------------------------

# Select the numeric variables that could eventually be
# used to predict whether an upset occurs.

numeric_predictors <- upset_data %>%
  select(
    SeedDifference,
    WinPctDifference,
    AvgPointsDifference,
    AvgPointsAllowedDifference,
    PointMarginDifference,
    FGPercentDifference,
    ThreePPercentDifference,
    FTPercentDifference,
    ReboundDifference,
    AssistDifference,
    TurnoverDifference,
    StealDifference,
    BlockDifference,
    SOSDifference
  )


# Calculate correlations between all predictor variables.
#
# This helps identify predictors that may contain very
# similar information.

correlation_matrix <- cor(
  numeric_predictors,
  use = "complete.obs"
)


# Display the correlations rounded to three decimals.

round(
  correlation_matrix,
  3
)


# ------------------------------------------------------------
# 14. CORRELATIONS WITH UPSET
# ------------------------------------------------------------

# Calculate simple correlations between each predictor
# and the Upset variable.
#
# This is exploratory only.
#
# A predictive model will be built later.

upset_correlations <- upset_data %>%
  select(
    SeedDifference,
    WinPctDifference,
    AvgPointsDifference,
    AvgPointsAllowedDifference,
    PointMarginDifference,
    FGPercentDifference,
    ThreePPercentDifference,
    FTPercentDifference,
    ReboundDifference,
    AssistDifference,
    TurnoverDifference,
    StealDifference,
    BlockDifference,
    SOSDifference,
    Upset
  ) %>%
  cor(
    use = "complete.obs"
  )


# Keep only each variable's correlation with Upset.

upset_correlations <- upset_correlations[
  ,
  "Upset"
]


# Sort the results.

upset_correlations <- sort(
  upset_correlations,
  decreasing = TRUE
)


# Display the results.
upset_correlations


# ------------------------------------------------------------
# 15. EXPORT SUMMARY TABLES
# ------------------------------------------------------------

# Save overall upset frequency.

write_csv(
  upset_summary,
  "data/upset_summary.csv"
)


# Save upset rates by seed difference.

write_csv(
  upsets_by_seed_difference,
  "data/upsets_by_seed_difference.csv"
)


# Save the statistical comparison between upsets
# and non-upsets.

write_csv(
  upset_comparison,
  "data/upset_statistic_comparison.csv"
)