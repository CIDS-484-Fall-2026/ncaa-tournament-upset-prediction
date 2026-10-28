# ============================================================
# NCAA Tournament Upset Prediction
# Script 01: Regular-Season Data Preparation
#
# Purpose:
# Convert detailed regular-season game results into one row
# per team per season and calculate regular-season statistics.
#
# This script also calculates Strength of Schedule (SOS).
# ============================================================


# ------------------------------------------------------------
# 1. LOAD PACKAGES
# ------------------------------------------------------------

library(tidyverse)


# ------------------------------------------------------------
# 2. IMPORT DATA
# ------------------------------------------------------------

# Detailed regular-season game results
regular_season <- read_csv(
  "data/MRegularSeasonDetailedResults.csv"
)

# Team names and IDs
teams <- read_csv(
  "data/MTeams.csv"
)


# ------------------------------------------------------------
# 3. CREATE WINNER TEAM-GAME OBSERVATIONS
# ------------------------------------------------------------

# The original Kaggle data stores winners and losers in
# separate sets of columns.
#
# This creates one observation for the winning team in
# every regular-season game.

winners <- regular_season %>%
  transmute(
    Season,
    TeamID = WTeamID,
    OpponentID = LTeamID,
    Win = 1,
    Points = WScore,
    PointsAllowed = LScore,
    FGM = WFGM,
    FGA = WFGA,
    ThreePM = WFGM3,
    ThreePA = WFGA3,
    FTM = WFTM,
    FTA = WFTA,
    OR = WOR,
    DR = WDR,
    Ast = WAst,
    TO = WTO,
    Stl = WStl,
    Blk = WBlk
  )


# ------------------------------------------------------------
# 4. CREATE LOSER TEAM-GAME OBSERVATIONS
# ------------------------------------------------------------

# Create the same variables for the losing team.

losers <- regular_season %>%
  transmute(
    Season,
    TeamID = LTeamID,
    OpponentID = WTeamID,
    Win = 0,
    Points = LScore,
    PointsAllowed = WScore,
    FGM = LFGM,
    FGA = LFGA,
    ThreePM = LFGM3,
    ThreePA = LFGA3,
    FTM = LFTM,
    FTA = LFTA,
    OR = LOR,
    DR = LDR,
    Ast = LAst,
    TO = LTO,
    Stl = LStl,
    Blk = LBlk
  )


# ------------------------------------------------------------
# 5. COMBINE WINNERS AND LOSERS
# ------------------------------------------------------------

# Every regular-season game now produces two rows:
#
# One row for the winner
# One row for the loser

team_games <- bind_rows(
  winners,
  losers
)


# ------------------------------------------------------------
# 6. CALCULATE GAME-LEVEL STATISTICS
# ------------------------------------------------------------

team_games <- team_games %>%
  mutate(
    
    # Field-goal percentage
    FGPercent = FGM / FGA,
    
    # Three-point percentage
    ThreePPercent = ThreePM / ThreePA,
    
    # Free-throw percentage
    FTPercent = FTM / FTA,
    
    # Total rebounds
    Rebounds = OR + DR,
    
    # Point differential
    PointMargin = Points - PointsAllowed
  )


# ------------------------------------------------------------
# 7. CREATE TEAM-SEASON STATISTICS
# ------------------------------------------------------------

# Aggregate all games played by each team during each season.

team_seasons <- team_games %>%
  group_by(
    Season,
    TeamID
  ) %>%
  summarise(
    
    # Number of games played
    Games = n(),
    
    # Number of wins
    Wins = sum(Win),
    
    # Winning percentage
    WinPct = mean(Win),
    
    # Average points scored
    AvgPoints = mean(Points),
    
    # Average points allowed
    AvgPointsAllowed = mean(PointsAllowed),
    
    # Average point margin
    AvgPointMargin = mean(PointMargin),
    
    # Season field-goal percentage
    FGPercent = sum(FGM) / sum(FGA),
    
    # Season three-point percentage
    ThreePPercent = sum(ThreePM) / sum(ThreePA),
    
    # Season free-throw percentage
    FTPercent = sum(FTM) / sum(FTA),
    
    # Average rebounds per game
    AvgRebounds = mean(Rebounds),
    
    # Average assists per game
    AvgAssists = mean(Ast),
    
    # Average turnovers per game
    AvgTurnovers = mean(TO),
    
    # Average steals per game
    AvgSteals = mean(Stl),
    
    # Average blocks per game
    AvgBlocks = mean(Blk),
    
    .groups = "drop"
  )


# ------------------------------------------------------------
# 8. CALCULATE OPPONENT WINNING PERCENTAGE
# ------------------------------------------------------------

# Strength of Schedule attempts to measure the quality of
# the opponents that each team played.
#
# First create a lookup table containing every team's
# winning percentage.

opponent_records <- team_seasons %>%
  select(
    Season,
    TeamID,
    WinPct
  ) %>%
  rename(
    OpponentID = TeamID,
    OpponentWinPct = WinPct
  )


# Attach the opponent's season winning percentage to
# every game.

team_games_sos <- team_games %>%
  left_join(
    opponent_records,
    by = c(
      "Season",
      "OpponentID"
    )
  )


# Calculate the average winning percentage of the teams
# that each team played.
#
# OWP = Opponents' Winning Percentage

team_owp <- team_games_sos %>%
  group_by(
    Season,
    TeamID
  ) %>%
  summarise(
    
    OWP = mean(
      OpponentWinPct,
      na.rm = TRUE
    ),
    
    .groups = "drop"
  )


# ------------------------------------------------------------
# 9. CALCULATE OPPONENTS' OPPONENTS' WINNING PERCENTAGE
# ------------------------------------------------------------

# Create a lookup table containing each team's OWP.

opponent_owp <- team_owp %>%
  select(
    Season,
    TeamID,
    OWP
  ) %>%
  rename(
    OpponentID = TeamID,
    OpponentOWP = OWP
  )


# Attach each opponent's OWP to every game.

team_games_sos <- team_games_sos %>%
  left_join(
    opponent_owp,
    by = c(
      "Season",
      "OpponentID"
    )
  )


# Calculate the average OWP of every team's opponents.
#
# OOWP = Opponents' Opponents' Winning Percentage

team_oowp <- team_games_sos %>%
  group_by(
    Season,
    TeamID
  ) %>%
  summarise(
    
    OOWP = mean(
      OpponentOWP,
      na.rm = TRUE
    ),
    
    .groups = "drop"
  )


# ------------------------------------------------------------
# 10. CALCULATE STRENGTH OF SCHEDULE
# ------------------------------------------------------------

# Combine OWP and OOWP.
#
# SOS is calculated as:
#
# SOS = (2/3 * OWP) + (1/3 * OOWP)

strength_of_schedule <- team_owp %>%
  left_join(
    team_oowp,
    by = c(
      "Season",
      "TeamID"
    )
  ) %>%
  mutate(
    
    SOS =
      (2 / 3) * OWP +
      (1 / 3) * OOWP
    
  )


# ------------------------------------------------------------
# 11. ADD SOS TO TEAM-SEASON STATISTICS
# ------------------------------------------------------------

team_seasons <- team_seasons %>%
  left_join(
    strength_of_schedule,
    by = c(
      "Season",
      "TeamID"
    )
  )


# ------------------------------------------------------------
# 12. ADD TEAM NAMES
# ------------------------------------------------------------

team_seasons <- team_seasons %>%
  left_join(
    
    teams %>%
      select(
        TeamID,
        TeamName
      ),
    
    by = "TeamID"
  )


# ------------------------------------------------------------
# 13. CHECK THE DATA
# ------------------------------------------------------------

# View the completed team-season dataset
View(team_seasons)


# Check the season range
range(team_seasons$Season)


# Check for missing SOS values
sum(is.na(team_seasons$SOS))


# Look at the distribution of SOS
summary(team_seasons$SOS)


# Display examples of teams with the strongest schedules
team_seasons %>%
  arrange(desc(SOS)) %>%
  select(
    Season,
    TeamName,
    WinPct,
    OWP,
    OOWP,
    SOS
  ) %>%
  head(20)


# ------------------------------------------------------------
# 14. EXPORT DATA
# ------------------------------------------------------------

# Save the updated team-season dataset.
#
# This will overwrite the previous version because it now
# contains the additional SOS variables.

write_csv(
  team_seasons,
  "data/team_season_statistics.csv"
)
