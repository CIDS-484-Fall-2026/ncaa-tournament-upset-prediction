Predicting NCAA Tournament Upsets

A sports analytics research project examining which regular-season team statistics are most useful for predicting upsets in the NCAA Men’s Basketball Tournament.

Overview

Tournament seeds provide an indication of team strength, but they do not fully explain why upsets occur. This project investigates whether regular-season statistics can help identify teams that are more likely to outperform their tournament seed.

Research question: Which regular-season team statistics are most useful for predicting upsets in the NCAA Men’s Basketball Tournament?

For this project, an upset occurs when a team with a larger numerical seed defeats a team with a smaller numerical seed. For example, if a 12 seed defeats a 5 seed, the game is classified as an upset.

Methods

The project will use NCAA regular-season and tournament data to compare the statistical profiles of tournament opponents.

The general process is:

Clean and combine regular-season results, tournament results, tournament seeds, and team information.

Calculate season-level statistics for each team.

Identify the favorite and underdog in each NCAA Tournament matchup based on tournament seed.

Compare regular-season statistics between the underdog and favorite.

Use logistic regression to estimate the probability of an upset.

Compare the statistical model with a model based primarily on tournament seeding.

Evaluate the model's predictive performance.

Potential Predictors

Regular-season statistics currently included in the analysis are:

Winning percentage

Average points scored

Average points allowed

Average scoring margin

Field-goal percentage

Three-point percentage

Free-throw percentage

Rebounds

Assists

Turnovers

Steals

Blocks

Tournament seed difference

For each tournament matchup, most regular-season predictors are represented as the difference between the underdog's statistic and the favorite's statistic.

Data Source

Data comes from Kaggle's March Machine Learning Mania 2026 competition.

The original files selected for this project are:

MRegularSeasonDetailedResults.csv

MNCAATourneyCompactResults.csv

MNCAATourneySeeds.csv

MTeams.csv

The project also creates two processed datasets:

team_season_statistics.csv

tournament_upset_data.csv

Detailed regular-season statistics are available beginning in 2003, so the primary analysis uses NCAA Tournament games from 2003 onward.

Project Files

01_data_preparation.R

This script prepares the regular-season data for analysis. The original game results store the winning and losing teams separately, so the script restructures the data to create one observation for each team's performance in each game.

It then calculates and summarizes regular-season statistics for every team-season, including winning percentage, scoring margin, shooting percentages, rebounds, assists, turnovers, steals, and blocks.

The resulting dataset is exported as:

team_season_statistics.csv

02_tournament_matchups.R

This script prepares the NCAA Tournament matchup data.

It:

Adds tournament seeds to each game.

Removes seasons before 2003 because detailed regular-season statistics are not available.

Identifies the favorite and underdog based on tournament seed.

Classifies whether each game resulted in an upset.

Adds the regular-season statistics created in Script 01.

Calculates the difference between the underdog and favorite for each statistic.

Creates the final dataset that will be used for exploratory analysis and predictive modeling.

The resulting dataset is exported as:

tournament_upset_data.csv

The current dataset contains 1,367 NCAA Tournament matchups from 2003 through 2025. Of those games, 392 are classified as upsets and 975 as non-upsets. The completed dataset contains no missing values.

Tools

R and RStudio for data preparation, analysis, visualization, and modeling

tidyverse for data manipulation

GitHub for project documentation and version control

Milestone 1 — Project Setup

For Milestone 1, I selected the research question, discussed the project with my faculty advisor, downloaded and initially examined the datasets, and identified relevant background articles.

I also identified the regular-season statistics that could potentially be useful for predicting tournament upsets.

Milestone 1 video:
https://youtu.be/RUV-nK5dAqw

Milestone 2 — Data Preparation

For Milestone 2, I focused on preparing the data needed for the actual analysis.

I first transformed the detailed regular-season game results into team-level observations and calculated season statistics for every team. These statistics include winning percentage, scoring margin, shooting percentages, rebounds, assists, turnovers, steals, and blocks.

I then prepared the NCAA Tournament results by adding each team's tournament seed and identifying the favorite and underdog in every matchup. Games are classified as upsets when the team with the larger numerical seed defeats the team with the smaller numerical seed.

Next, I joined the regular-season statistics to the tournament matchups. For each matchup, I calculated the difference between the underdog and favorite for each regular-season statistic. This creates a set of matchup-level predictors that can be used to investigate which differences are associated with a greater probability of an upset.

The final analysis dataset currently contains 1,367 tournament games from 2003 through 2025, with 392 upsets and 975 non-upsets. There are no missing values in the final dataset.

Next Steps

The next stage of the project will focus on exploratory data analysis. I plan to examine how the statistical differences vary between upsets and non-upsets, create visualizations, and investigate relationships between the potential predictors and upset outcomes.

After the exploratory analysis, I will begin developing the logistic regression model used to predict upset probability and evaluate which regular-season statistics are most useful.

Milestone 2 video:
Link will be added after the Milestone 2 video is completed.

References

Dartmouth Sports Analytics: First-round upset indicators

Matt Worley: Predicting Upsets with Machine Learning

Dutta, S., Jacobson, S. H., & Sauppe, J. J. (2017). Identifying NCAA tournament upsets using Balance Optimization Subset Selection. Journal of Quantitative Analysis in Sports, 13(2), 79–93.

Author

Albert Blair
Mathematics and Data Science
University of Wisconsin–River Falls
CIDS 488 — Senior Capstone, Fall 2026
