# ============================================================
# NCAA Tournament Upset Prediction
# Script 02: Create Tournament Matchup Dataset
#
# Purpose:
# Combine tournament results, tournament seeds, and
# regular-season team statistics.
#
# The final dataset contains one row per tournament matchup.
# ============================================================


# ------------------------------------------------------------
# 1. LOAD PACKAGES
# ------------------------------------------------------------

library(tidyverse)


# ------------------------------------------------------------
# 2. IMPORT DATA
# ------------------------------------------------------------

# NCAA Tournament game results
tourney_results <- read_csv(
  "data/MNCAATourneyCompactResults.csv"
)

# NCAA Tournament seeds
tourney_seeds <- read_csv(
  "data/MNCAATourneySeeds.csv"
)

# Team names
teams <- read_csv(
  "data/MTeams.csv"
)

# Team-season statistics created in Script 01
team_seasons <- read_csv(
  "data/team_season_statistics.csv"
)


# ------------------------------------------------------------
# 3. CLEAN TOURNAMENT SEEDS
# ------------------------------------------------------------

# Tournament seeds are stored as values such as:
#
# W01
# X12
# W16a
#
# Extract only the numeric portion.

tourney_seeds <- tourney_seeds %>%
  mutate(
    
    SeedNum =
      as.numeric(
        str_extract(
          Seed,
          "\\d+"
        )
      )
    
  )


# ------------------------------------------------------------
# 4. ADD SEEDS TO TOURNAMENT RESULTS
# ------------------------------------------------------------

# Add the winning team's seed.

tournament_games <- tourney_results %>%
  left_join(
    
    tourney_seeds %>%
      select(
        Season,
        TeamID,
        SeedNum
      ) %>%
      rename(
        WTeamID = TeamID,
        WSeed = SeedNum
      ),
    
    by = c(
      "Season",
      "WTeamID"
    )
  )


# Add the losing team's seed.

tournament_games <- tournament_games %>%
  left_join(
    
    tourney_seeds %>%
      select(
        Season,
        TeamID,
        SeedNum
      ) %>%
      rename(
        LTeamID = TeamID,
        LSeed = SeedNum
      ),
    
    by = c(
      "Season",
      "LTeamID"
    )
  )


# ------------------------------------------------------------
# 5. SELECT GAMES FOR THE ANALYSIS
# ------------------------------------------------------------

# Detailed regular-season statistics begin in 2003.
#
# Therefore, tournament games before 2003 are removed.
#
# Games where both teams have the same seed are also removed
# because there is no clear favorite or underdog based on seed.

tournament_games <- tournament_games %>%
  filter(
    Season >= 2003,
    WSeed != LSeed
  )


# ------------------------------------------------------------
# 6. IDENTIFY FAVORITE AND UNDERDOG
# ------------------------------------------------------------

# Smaller seed number = Favorite
# Larger seed number = Underdog
#
# Example:
#
# #4 vs #13
#
# #4 = Favorite
# #13 = Underdog

tournament_games <- tournament_games %>%
  mutate(
    
    FavoriteTeamID =
      if_else(
        WSeed < LSeed,
        WTeamID,
        LTeamID
      ),
    
    UnderdogTeamID =
      if_else(
        WSeed > LSeed,
        WTeamID,
        LTeamID
      ),
    
    FavoriteSeed =
      pmin(
        WSeed,
        LSeed
      ),
    
    UnderdogSeed =
      pmax(
        WSeed,
        LSeed
      )
    
  )


# ------------------------------------------------------------
# 7. CREATE THE UPSET VARIABLE
# ------------------------------------------------------------

# Upset = 1 when the underdog wins
# Upset = 0 when the favorite wins
#
# Because larger seed numbers represent underdogs,
# an upset occurs when WSeed > LSeed.

tournament_games <- tournament_games %>%
  mutate(
    
    Upset =
      if_else(
        WSeed > LSeed,
        1,
        0
      ),
    
    # Difference between tournament seeds
    SeedDifference =
      UnderdogSeed - FavoriteSeed
    
  )


# ------------------------------------------------------------
# 8. ADD TEAM NAMES
# ------------------------------------------------------------

favorite_names <- teams %>%
  select(
    TeamID,
    TeamName
  ) %>%
  rename(
    FavoriteTeamID = TeamID,
    FavoriteTeam = TeamName
  )


underdog_names <- teams %>%
  select(
    TeamID,
    TeamName
  ) %>%
  rename(
    UnderdogTeamID = TeamID,
    UnderdogTeam = TeamName
  )


tournament_games <- tournament_games %>%
  left_join(
    favorite_names,
    by = "FavoriteTeamID"
  ) %>%
  left_join(
    underdog_names,
    by = "UnderdogTeamID"
  )


# ------------------------------------------------------------
# 9. PREPARE FAVORITE STATISTICS
# ------------------------------------------------------------

favorite_stats <- team_seasons %>%
  select(
    Season,
    TeamID,
    WinPct,
    AvgPoints,
    AvgPointsAllowed,
    AvgPointMargin,
    FGPercent,
    ThreePPercent,
    FTPercent,
    AvgRebounds,
    AvgAssists,
    AvgTurnovers,
    AvgSteals,
    AvgBlocks,
    SOS
  ) %>%
  rename(
    FavoriteTeamID = TeamID,
    FavWinPct = WinPct,
    FavAvgPoints = AvgPoints,
    FavAvgPointsAllowed = AvgPointsAllowed,
    FavAvgPointMargin = AvgPointMargin,
    FavFGPercent = FGPercent,
    FavThreePPercent = ThreePPercent,
    FavFTPercent = FTPercent,
    FavAvgRebounds = AvgRebounds,
    FavAvgAssists = AvgAssists,
    FavAvgTurnovers = AvgTurnovers,
    FavAvgSteals = AvgSteals,
    FavAvgBlocks = AvgBlocks,
    FavSOS = SOS
  )


# ------------------------------------------------------------
# 10. PREPARE UNDERDOG STATISTICS
# ------------------------------------------------------------

underdog_stats <- team_seasons %>%
  select(
    Season,
    TeamID,
    WinPct,
    AvgPoints,
    AvgPointsAllowed,
    AvgPointMargin,
    FGPercent,
    ThreePPercent,
    FTPercent,
    AvgRebounds,
    AvgAssists,
    AvgTurnovers,
    AvgSteals,
    AvgBlocks,
    SOS
  ) %>%
  rename(
    UnderdogTeamID = TeamID,
    DogWinPct = WinPct,
    DogAvgPoints = AvgPoints,
    DogAvgPointsAllowed = AvgPointsAllowed,
    DogAvgPointMargin = AvgPointMargin,
    DogFGPercent = FGPercent,
    DogThreePPercent = ThreePPercent,
    DogFTPercent = FTPercent,
    DogAvgRebounds = AvgRebounds,
    DogAvgAssists = AvgAssists,
    DogAvgTurnovers = AvgTurnovers,
    DogAvgSteals = AvgSteals,
    DogAvgBlocks = AvgBlocks,
    DogSOS = SOS
  )


# ------------------------------------------------------------
# 11. JOIN REGULAR-SEASON STATISTICS
# ------------------------------------------------------------

# Add the favorite's statistics.

tournament_games <- tournament_games %>%
  left_join(
    favorite_stats,
    by = c(
      "Season",
      "FavoriteTeamID"
    )
  )


# Add the underdog's statistics.

tournament_games <- tournament_games %>%
  left_join(
    underdog_stats,
    by = c(
      "Season",
      "UnderdogTeamID"
    )
  )


# ------------------------------------------------------------
# 12. CALCULATE MATCHUP DIFFERENCES
# ------------------------------------------------------------

# Every difference is calculated as:
#
# UNDERDOG - FAVORITE
#
# Positive = underdog had the higher value
# Negative = favorite had the higher value

tournament_games <- tournament_games %>%
  mutate(
    
    WinPctDifference =
      DogWinPct - FavWinPct,
    
    AvgPointsDifference =
      DogAvgPoints - FavAvgPoints,
    
    AvgPointsAllowedDifference =
      DogAvgPointsAllowed - FavAvgPointsAllowed,
    
    PointMarginDifference =
      DogAvgPointMargin - FavAvgPointMargin,
    
    FGPercentDifference =
      DogFGPercent - FavFGPercent,
    
    ThreePPercentDifference =
      DogThreePPercent - FavThreePPercent,
    
    FTPercentDifference =
      DogFTPercent - FavFTPercent,
    
    ReboundDifference =
      DogAvgRebounds - FavAvgRebounds,
    
    AssistDifference =
      DogAvgAssists - FavAvgAssists,
    
    TurnoverDifference =
      DogAvgTurnovers - FavAvgTurnovers,
    
    StealDifference =
      DogAvgSteals - FavAvgSteals,
    
    BlockDifference =
      DogAvgBlocks - FavAvgBlocks,
    
    # Positive SOS difference means the underdog played
    # the stronger regular-season schedule.
    SOSDifference =
      DogSOS - FavSOS
    
  )


# ------------------------------------------------------------
# 13. CREATE FINAL ANALYSIS DATASET
# ------------------------------------------------------------

upset_data <- tournament_games %>%
  select(
    
    Season,
    
    FavoriteTeam,
    UnderdogTeam,
    
    FavoriteSeed,
    UnderdogSeed,
    
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
  )


# ------------------------------------------------------------
# 14. CHECK FINAL DATASET
# ------------------------------------------------------------

# Number of upsets and non-upsets
table(upset_data$Upset)


# Percentage of games that were upsets
prop.table(
  table(upset_data$Upset)
)


# Check missing values
colSums(
  is.na(upset_data)
)


# Check season range
range(
  upset_data$Season
)


# Check dataset dimensions
dim(
  upset_data
)


# View the final dataset
View(
  upset_data
)


# ------------------------------------------------------------
# 15. EXPORT FINAL DATASET
# ------------------------------------------------------------

write_csv(
  upset_data,
  "data/tournament_upset_data.csv"
)
