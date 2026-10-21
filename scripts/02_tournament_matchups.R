# Load tidyverse for importing, cleaning, joining, and manipulating data
library(tidyverse)


# ------------------------------------------------------------
# 1. IMPORT DATA
# ------------------------------------------------------------

# Import NCAA Tournament results
# Each row represents one NCAA Tournament game
tourney_results <- read_csv("data/MNCAATourneyCompactResults.csv")

# Import NCAA Tournament seeds
# This contains the tournament seed assigned to each team
tourney_seeds <- read_csv("data/MNCAATourneySeeds.csv")

# Import team information
# This allows TeamID values to be matched with actual team names
teams <- read_csv("data/MTeams.csv")

# Import the team-season statistics created in Script 01
# Each row represents one team's regular-season performance
# during one season
team_seasons <- read_csv("data/team_season_statistics.csv")



# ------------------------------------------------------------
# 2. CLEAN TOURNAMENT SEEDS
# ------------------------------------------------------------

# Tournament seeds are stored as values such as W01, X12,
# or W16a. Extract only the numeric portion of the seed.
#
# Examples:
# W01  -> 1
# X12  -> 12
# W16a -> 16
tourney_seeds <- tourney_seeds %>%
  mutate(
    SeedNum = as.numeric(str_extract(Seed, "\\d+"))
  )



# ------------------------------------------------------------
# 3. ADD SEEDS TO TOURNAMENT RESULTS
# ------------------------------------------------------------

# Add the tournament seed of the winning team to each game
tournament_games <- tourney_results %>%
  left_join(
    tourney_seeds %>%
      select(Season, TeamID, SeedNum) %>%
      rename(
        WTeamID = TeamID,
        WSeed = SeedNum
      ),
    by = c("Season", "WTeamID")
  )


# Add the tournament seed of the losing team to each game
tournament_games <- tournament_games %>%
  left_join(
    tourney_seeds %>%
      select(Season, TeamID, SeedNum) %>%
      rename(
        LTeamID = TeamID,
        LSeed = SeedNum
      ),
    by = c("Season", "LTeamID")
  )



# ------------------------------------------------------------
# 4. SELECT GAMES FOR THE ANALYSIS
# ------------------------------------------------------------

# Detailed regular-season statistics are available beginning
# in 2003, so tournament games before 2003 cannot be used
# for the statistical analysis.
#
# Games where both teams have the same seed are also removed
# because there is no clear favorite or underdog based on seed.
tournament_games <- tournament_games %>%
  filter(
    Season >= 2003,
    WSeed != LSeed
  )



# ------------------------------------------------------------
# 5. IDENTIFY THE FAVORITE AND UNDERDOG
# ------------------------------------------------------------

# The team with the smaller seed number is considered the favorite.
# The team with the larger seed number is considered the underdog.
#
# For example:
# Seed 4 = Favorite
# Seed 13 = Underdog
#
# These are determined independently of which team actually won.
tournament_games <- tournament_games %>%
  mutate(
    FavoriteTeamID = if_else(WSeed < LSeed, WTeamID, LTeamID),
    UnderdogTeamID = if_else(WSeed > LSeed, WTeamID, LTeamID),
    
    FavoriteSeed = pmin(WSeed, LSeed),
    UnderdogSeed = pmax(WSeed, LSeed)
  )



# ------------------------------------------------------------
# 6. IDENTIFY UPSETS
# ------------------------------------------------------------

# Create the response variable for the project.
#
# Upset = 1 when the lower-seeded team wins
# Upset = 0 when the higher-seeded team wins
#
# Because a larger seed number represents the underdog,
# an upset occurs when WSeed is greater than LSeed.
#
# Also calculate the difference between the two teams' seeds.
tournament_games <- tournament_games %>%
  mutate(
    Upset = if_else(WSeed > LSeed, 1, 0),
    SeedDifference = UnderdogSeed - FavoriteSeed
  )



# ------------------------------------------------------------
# 7. ADD TEAM NAMES
# ------------------------------------------------------------

# Create a lookup table for the favorite's team name
favorite_names <- teams %>%
  select(TeamID, TeamName) %>%
  rename(
    FavoriteTeamID = TeamID,
    FavoriteTeam = TeamName
  )


# Create a lookup table for the underdog's team name
underdog_names <- teams %>%
  select(TeamID, TeamName) %>%
  rename(
    UnderdogTeamID = TeamID,
    UnderdogTeam = TeamName
  )


# Join the team names onto each tournament matchup
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
# 8. PREPARE FAVORITE REGULAR-SEASON STATISTICS
# ------------------------------------------------------------

# Select the regular-season statistics that will be used
# for the favorite in each tournament matchup.
#
# Variables are renamed with "Fav" so they can be distinguished
# from the underdog's statistics after the datasets are joined.
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
    AvgBlocks
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
    FavAvgBlocks = AvgBlocks
  )



# ------------------------------------------------------------
# 9. PREPARE UNDERDOG REGULAR-SEASON STATISTICS
# ------------------------------------------------------------

# Select the same regular-season statistics for the underdog.
#
# Variables are renamed with "Dog" so they can be distinguished
# from the favorite's statistics.
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
    AvgBlocks
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
    DogAvgBlocks = AvgBlocks
  )



# ------------------------------------------------------------
# 10. ADD REGULAR-SEASON STATISTICS TO EACH MATCHUP
# ------------------------------------------------------------

# Join the favorite's regular-season statistics to each
# tournament game using Season and TeamID
tournament_games <- tournament_games %>%
  left_join(
    favorite_stats,
    by = c("Season", "FavoriteTeamID")
  )


# Join the underdog's regular-season statistics to each
# tournament game using Season and TeamID
tournament_games <- tournament_games %>%
  left_join(
    underdog_stats,
    by = c("Season", "UnderdogTeamID")
  )



# ------------------------------------------------------------
# 11. CALCULATE MATCHUP DIFFERENCES
# ------------------------------------------------------------

# Calculate the difference between the underdog and favorite
# for each regular-season statistic.
#
# All differences are calculated as:
#
#       Underdog Statistic - Favorite Statistic
#
# This provides one matchup-level value for each statistic.
#
# A positive value means the underdog had a higher value
# for that statistic during the regular season.
#
# A negative value means the favorite had a higher value.
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
      DogAvgBlocks - FavAvgBlocks
  )



# ------------------------------------------------------------
# 12. CREATE THE FINAL ANALYSIS DATASET
# ------------------------------------------------------------

# Keep the variables needed for the upset analysis.
#
# Each row in upset_data now represents one NCAA Tournament
# matchup between a favorite and an underdog.
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
    
    Upset
  )



# ------------------------------------------------------------
# 13. CHECK THE FINAL DATASET
# ------------------------------------------------------------

# Display the number of tournament games classified as
# non-upsets and upsets.
#
# 0 = Favorite won
# 1 = Underdog won
table(upset_data$Upset)


# Check every variable for missing values.
# Ideally the statistical variables should no longer contain
# missing values now that the analysis begins in 2003.
colSums(is.na(upset_data))


# Check the range of seasons included in the final dataset.
# The first season should now be 2003.
range(upset_data$Season)


# Display the number of rows and columns in the final dataset
dim(upset_data)


# Open the final dataset for visual inspection
View(upset_data)



# ------------------------------------------------------------
# 14. EXPORT THE FINAL DATASET
# ------------------------------------------------------------

# Save the completed tournament matchup dataset.
#
# This dataset will be used in the next stages of the project
# for exploratory data analysis and predictive modeling.
write_csv(
  upset_data,
  "data/tournament_upset_data.csv"
)
