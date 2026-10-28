# Predicting NCAA Tournament Upsets

A sports analytics research project examining which regular-season team statistics are most useful for predicting upsets in the NCAA Men’s Basketball Tournament.

## Overview

Tournament seeds provide an indication of team strength, but they do not fully explain why upsets occur. This project investigates whether regular-season statistics can help identify teams likely to outperform their tournament seed.

**Research Question:** Which regular-season team statistics are most useful for predicting upsets in the NCAA Men’s Basketball Tournament?

For this project, an upset occurs when a team with a larger numerical seed defeats a team with a smaller numerical seed.

## Methods

The project uses regular-season and NCAA Tournament data beginning with the 2003 season because detailed regular-season statistics are available starting in 2003.

The analysis process includes:

- Cleaning and combining regular-season results, tournament results, tournament seeds, and team information.
- Calculating season-level statistics for each team.
- Creating NCAA Tournament matchups between the favorite and underdog based on tournament seeds.
- Comparing the regular-season statistical profiles of the two teams in each matchup.
- Creating predictor variables representing the difference between the underdog and favorite.
- Using logistic regression to estimate the probability of an upset.
- Comparing the predictive model with tournament seeds.
- Evaluating model performance on later seasons.

## Potential Predictors

Regular-season statistics being considered include:

- Winning percentage
- Average points scored
- Average field goals attempted
- Average three-point attempts
- Average free-throw attempts
- Average offensive rebounds
- Average defensive rebounds
- Average assists
- Average turnovers
- Average steals
- Average blocks
- Strength of schedule

For tournament matchups, statistical differences are calculated as:

**Underdog Statistic - Favorite Statistic**

Therefore, a positive difference means the underdog had a higher value for that statistic during the regular season, while a negative difference means the favorite had the higher value.

The final set of predictors will be determined through exploratory analysis and model evaluation.

## Data Source

Data comes from Kaggle's March Machine Learning Mania 2026 dataset.

Files used:

- `MRegularSeasonDetailedResults.csv`
- `MNCAATourneyCompactResults.csv`
- `MNCAATourneySeeds.csv`
- `MTeams.csv`

## Project Files

### `01_data_preparation.R`

This script prepares the regular-season data.

It:

- Loads the NCAA datasets.
- Separates each regular-season game into winner and loser perspectives.
- Converts the results into team-game observations.
- Creates statistics for both the team and its opponent.
- Combines all team-game observations.
- Calculates season-level statistics for every team.

The resulting team-season dataset is saved as:

`team_season_statistics.csv`

### `02_tournament_matchups.R`

This script prepares the NCAA Tournament matchup data.

It:

- Loads tournament results and tournament seeds.
- Extracts the numerical portion of each tournament seed.
- Determines the favorite and underdog in each matchup.
- Identifies whether an upset occurred.
- Joins regular-season statistics for both teams.
- Calculates differences between the underdog's and favorite's regular-season statistics.
- Adds team names to make the dataset easier to interpret.

The resulting tournament dataset is saved as:

`tournament_upset_data.csv`

The current dataset contains **1,367 NCAA Tournament matchups from 2003 through 2025**, including:

- **392 upsets**
- **975 non-upsets**
- **No missing values**

## Tools

- R and RStudio for data preparation, analysis, and visualization
- tidyverse for data manipulation
- GitHub for project documentation and version control

## Milestone 1

For Milestone 1, I selected my research question, discussed the project with my faculty advisor, downloaded and examined the datasets, and identified relevant background articles related to NCAA Tournament upset prediction.

I also established the overall direction of the project and identified regular-season team statistics that could potentially help explain tournament upsets.

**Milestone 1 Video:**  
https://youtu.be/RUV-nK5dAqw

## Milestone 2

For Milestone 2, I began the main data preparation process for the project.

The first R script transforms the detailed regular-season results into a team-level format. Because the original NCAA dataset records statistics separately for the winning and losing teams, the data is reorganized so that every team receives its own observation for each game.

These game-level observations are then summarized to create season-level statistics for every team.

The second script combines these regular-season statistics with NCAA Tournament results and tournament seeds. Each tournament matchup is organized into a favorite and an underdog based on seed.

An upset indicator is created where:

- `1` = the underdog won
- `0` = the favorite won

Predictor variables are then calculated using:

**Underdog Statistic - Favorite Statistic**

This allows the model to measure how the underdog compares with the favorite in different statistical categories.

The prepared tournament dataset currently includes NCAA Tournament games from 2003 through 2025.

The next stage of the project will involve exploratory data analysis to determine which statistical differences appear most strongly associated with tournament upsets. After this analysis, logistic regression models will be developed to estimate upset probabilities and evaluate which regular-season statistics provide the most predictive value.

**Milestone 2 Video:**  


## Next Steps

The next steps for the project include:

- Add a strength-of-schedule measure for each team.
- Explore differences between upset and non-upset games.
- Create visualizations for important predictors.
- Examine relationships between predictor variables.
- Determine which predictors should be included in the model.
- Build a logistic regression model for upset probability.
- Compare model predictions with tournament seeds.
- Evaluate predictive performance using later tournament seasons.

## References

- Dartmouth Sports Analytics: First-round upset indicators
- Matt Worley: Predicting Upsets with Machine Learning
- Dutta, S., Jacobson, S. H., & Sauppe, J. J. (2017). *Identifying NCAA tournament upsets using Balance Optimization Subset Selection.*

## Author

Albert Blair  
Mathematics and Data Science  
University of Wisconsin–River Falls  
CIDS 488 — Senior Capstone, Fall 2026
