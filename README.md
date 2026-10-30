# Predicting NCAA Tournament Upsets

A sports analytics research project examining which regular-season team statistics are most useful for predicting upsets in the NCAA Men’s Basketball Tournament.

## Overview

Tournament seeds provide an indication of team strength, but they do not fully explain why upsets occur. This project investigates whether regular-season statistics can help identify teams likely to outperform their tournament seed.

**Research Question:** Which regular-season team statistics are most useful for predicting upsets in the NCAA Men’s Basketball Tournament?

For this project, an upset occurs when a team with a larger numerical seed defeats a team with a smaller numerical seed.

The analysis includes NCAA Tournament games from **all tournament rounds**, rather than only first-round matchups.

## Methods

The project uses regular-season and NCAA Tournament data beginning with the 2003 season because detailed regular-season statistics are available starting in 2003.

The analysis process includes:

- Cleaning and combining regular-season results, tournament results, tournament seeds, and team information.
- Calculating season-level statistics for each team.
- Calculating a strength-of-schedule measure using opponent winning percentage and opponents' opponent winning percentage.
- Creating NCAA Tournament matchups between the favorite and underdog based on tournament seeds.
- Comparing the regular-season statistical profiles of the two teams in each matchup.
- Creating predictor variables representing the difference between the underdog and favorite.
- Conducting exploratory analysis to identify variables associated with tournament upsets.
- Using logistic regression to estimate the probability of an upset.
- Comparing the predictive model with tournament seeds.
- Evaluating model performance on later seasons.

## Potential Predictors

Regular-season statistics being considered include:

- Winning percentage
- Average points scored
- Average points allowed
- Average point margin
- Field-goal percentage
- Three-point percentage
- Free-throw percentage
- Average rebounds
- Average assists
- Average turnovers
- Average steals
- Average blocks
- Strength of schedule
- Tournament seed difference

For tournament matchups, statistical differences are calculated as:

**Underdog Statistic - Favorite Statistic**

Therefore, a positive difference means the underdog had a higher value for that statistic during the regular season, while a negative difference means the favorite had the higher value.

The final set of predictors will be determined through exploratory analysis and model evaluation.

## Strength of Schedule

A strength-of-schedule variable was added to provide additional context for each team's regular-season performance.

Strength of schedule is calculated using:

- **OWP:** Average winning percentage of a team's opponents.
- **OOWP:** Average opponent winning percentage of those opponents.

The project-level strength-of-schedule measure is calculated as:

**SOS = (2/3 × OWP) + (1/3 × OOWP)**

For tournament matchups, `SOSDifference` is calculated as:

**Underdog SOS - Favorite SOS**

A positive value means the underdog played the stronger regular-season schedule, while a negative value means the favorite played the stronger schedule.

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
- Calculates game-level statistics.
- Summarizes the game-level data into season-level statistics for every team.
- Calculates opponent winning percentage (OWP).
- Calculates opponents' opponent winning percentage (OOWP).
- Creates the strength-of-schedule measure.
- Adds team names to the season-level dataset.

The resulting team-season dataset is saved as:

`team_season_statistics.csv`

### `02_tournament_matchups.R`

This script prepares the NCAA Tournament matchup data.

It:

- Loads tournament results and tournament seeds.
- Restricts the analysis to seasons beginning in 2003.
- Extracts the numerical portion of each tournament seed.
- Determines the favorite and underdog in each matchup.
- Identifies whether an upset occurred.
- Joins regular-season statistics for both teams.
- Calculates differences between the underdog's and favorite's regular-season statistics.
- Includes strength-of-schedule difference as a predictor.
- Adds team names to make the dataset easier to interpret.

The resulting tournament dataset is saved as:

`tournament_upset_data.csv`

The dataset contains **1,367 NCAA Tournament matchups from 2003 through 2025**, including:

- **392 upsets (28.7%)**
- **975 non-upsets (71.3%)**
- **No missing values**

### `03_exploratory_analysis.R`

This script performs exploratory analysis on the tournament matchup dataset.

It:

- Calculates the overall frequency of tournament upsets.
- Examines upset rates at different tournament seed differences.
- Compares regular-season statistical differences between upsets and non-upsets.
- Creates boxplots for several potential predictors.
- Examines correlations among predictor variables.
- Calculates simple correlations between each predictor and the upset indicator.
- Creates summary datasets for use in interpreting the results.

The exploratory analysis produces:

- `upset_summary.csv`
- `upsets_by_seed_difference.csv`
- `upset_statistic_comparison.csv`

## Exploratory Analysis Results

Of the **1,367 tournament games** included in the analysis:

- **392 (28.7%)** were upsets.
- **975 (71.3%)** were won by the favorite.

The exploratory results suggest that upsets are more likely when the statistical difference between the underdog and favorite is smaller.

Several variables showed notable relationships with the upset indicator:

- **Seed Difference:** -0.282
- **Point Margin Difference:** 0.231
- **Strength of Schedule Difference:** 0.194
- **Win Percentage Difference:** 0.148
- **Turnover Difference:** -0.101
- **Field-Goal Percentage Difference:** 0.098

Seed difference had the strongest relationship with the upset indicator. As the difference between the favorite's and underdog's seeds increased, upsets generally became less common.

Point margin also showed a notable relationship with upsets. In games won by the favorite, the underdog averaged a point-margin disadvantage of approximately **4.69 points** compared with the favorite. In upset games, that disadvantage was only approximately **1.95 points**.

Strength of schedule also showed a relationship with tournament upsets. When the favorite won, the average SOS difference was approximately **-0.041**. In upset games, the average SOS difference was approximately **-0.021**. This suggests that underdogs that won tended to have a smaller strength-of-schedule disadvantage relative to the favorite.

Overall, the exploratory analysis suggests that upset-winning underdogs tend to be more statistically similar to their favored opponents than underdogs that lose. These relationships will be investigated further during predictive modeling.

## Tools

- R and RStudio for data preparation, analysis, and visualization
- tidyverse for data manipulation
- ggplot2 for visualization
- GitHub for project documentation and version control

## Milestone 1

For Milestone 1, I selected my research question, discussed the project with my faculty advisor, downloaded and examined the datasets, and identified relevant background articles related to NCAA Tournament upset prediction.

I also established the overall direction of the project and identified regular-season team statistics that could potentially help explain tournament upsets.

**Milestone 1 Video:**  
https://youtu.be/RUV-nK5dAqw

## Milestone 2

For Milestone 2, I completed the main data preparation process and began the exploratory analysis of NCAA Tournament upsets.

The first R script transforms the detailed regular-season results into a team-level format. Because the original NCAA dataset records statistics separately for the winning and losing teams, the data is reorganized so that every team receives its own observation for each game. These game-level observations are then summarized to create season-level statistics for every team.

A strength-of-schedule measure was also added using opponent winning percentage and opponents' opponent winning percentage. This provides additional context for team performance by accounting for the quality of competition faced during the regular season.

The second script combines the regular-season statistics with NCAA Tournament results and tournament seeds. Each tournament matchup is organized into a favorite and an underdog based on seed. The analysis includes tournament games from all rounds beginning in 2003.

An upset indicator is created where:

- `1` = the underdog won
- `0` = the favorite won

Predictor variables are calculated using:

**Underdog Statistic - Favorite Statistic**

The third script performs exploratory analysis on the completed tournament dataset. The analysis compares upset and non-upset games, examines upset rates by seed difference, creates visualizations for several potential predictors, and examines correlations between regular-season statistical differences and tournament upsets.

The dataset contains **1,367 tournament matchups**, of which **392 (28.7%)** were upsets.

Initial results indicate that seed difference, regular-season point-margin difference, strength-of-schedule difference, and winning-percentage difference are among the variables most strongly associated with tournament upsets.

The next stage of the project will use these results to guide predictive modeling. Logistic regression models will be developed to estimate upset probabilities and determine whether regular-season statistics provide predictive value beyond tournament seeds alone.

**Milestone 2 Video:**  


## Next Steps

The next steps for the project include:

- Use the exploratory results to select and evaluate potential predictors.
- Examine multicollinearity among related regular-season statistics.
- Build a baseline model using tournament seed information.
- Build a logistic regression model incorporating regular-season statistics.
- Determine whether regular-season statistics improve prediction beyond tournament seeds.
- Evaluate model performance using later tournament seasons.
- Interpret which variables provide the most useful information for predicting tournament upsets.

## References

- Dartmouth Sports Analytics: First-round upset indicators
- Matt Worley: Predicting Upsets with Machine Learning
- Dutta, S., Jacobson, S. H., & Sauppe, J. J. (2017). *Identifying NCAA tournament upsets using Balance Optimization Subset Selection.*

## Author

Albert Blair  
Mathematics and Data Science  
University of Wisconsin–River Falls  
CIDS 488 — Senior Capstone, Fall 2026
