# Load the tidyverse package for importing, cleaning, and manipulating data
library(tidyverse)


# Import the four datasets used for the project
# Regular season detailed results contain game-level statistics for winning
# and losing teams
regular_season <- read_csv("data/MRegularSeasonDetailedResults.csv")

# NCAA Tournament results contain the winner and loser of each tournament game
tourney_results <- read_csv("data/MNCAATourneyCompactResults.csv")

# Tournament seeds contain each team's seed for each NCAA Tournament
tourney_seeds <- read_csv("data/MNCAATourneySeeds.csv")

# Teams dataset connects TeamID values to actual school/team names
teams <- read_csv("data/MTeams.csv")



# Create a dataset containing the winning team's performance from each
# regular-season game
# The original dataset stores winner statistics with a W prefix and loser
# statistics with an L prefix, so these are renamed to common variable names
winners <- regular_season %>%
  transmute(
    Season = Season,
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


# Create the same structure for losing teams
# Win is set equal to 0 and the L-prefixed statistics are used for the
# team's performance
losers <- regular_season %>%
  transmute(
    Season = Season,
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


# Combine the winner and loser datasets
# Each game now appears twice: once from each team's perspective
team_games <- bind_rows(winners, losers)


# Calculate additional statistics for each team's individual game
team_games <- team_games %>%
  mutate(
    # Field goal percentage
    FGPercent = FGM / FGA,
    
    # Three-point shooting percentage
    ThreePPercent = ThreePM / ThreePA,
    
    # Free-throw percentage
    FTPercent = FTM / FTA,
    
    # Total rebounds = offensive rebounds + defensive rebounds
    Rebounds = OR + DR,
    
    # Point differential for the game
    PointMargin = Points - PointsAllowed
  )


# Aggregate the individual game data into one observation for each
# team during each season
team_seasons <- team_games %>%
  group_by(Season, TeamID) %>%
  summarise(
    # Number of regular-season games played
    Games = n(),
    
    # Number of games won
    Wins = sum(Win),
    
    # Proportion of games won
    WinPct = mean(Win),
    
    # Average points scored, points allowed, and scoring margin
    AvgPoints = mean(Points),
    AvgPointsAllowed = mean(PointsAllowed),
    AvgPointMargin = mean(PointMargin),
    
    # Calculate season shooting percentages using total makes and attempts
    FGPercent = sum(FGM) / sum(FGA),
    ThreePPercent = sum(ThreePM) / sum(ThreePA),
    FTPercent = sum(FTM) / sum(FTA),
    
    # Calculate average box-score statistics per game
    AvgRebounds = mean(Rebounds),
    AvgAssists = mean(Ast),
    AvgTurnovers = mean(TO),
    AvgSteals = mean(Stl),
    AvgBlocks = mean(Blk),
    
    # Remove the grouping after the summary is completed
    .groups = "drop"
  )


# Add the actual team name to each TeamID
# TeamID is used to match team_seasons with the teams dataset
team_seasons <- team_seasons %>%
  left_join(
    teams %>% select(TeamID, TeamName),
    by = "TeamID"
  )


# Export the completed team-season statistics dataset as a new CSV file
# This file contains one row for each team in each season and will later
# be joined with NCAA Tournament results and seeds for the upset analysis
write_csv(
  team_seasons,
  "data/team_season_statistics.csv"
)
