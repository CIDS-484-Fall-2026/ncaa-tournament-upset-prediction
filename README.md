# Predicting NCAA Tournament Upsets

A sports analytics research project examining which regular-season team
statistics are most useful for predicting upsets in the NCAA Men’s
Basketball Tournament.

## Overview

Tournament seeds provide an indication of team strength, but they do not
fully explain why upsets occur. This project will investigate whether
regular-season statistics can help identify teams likely to outperform
their tournament seed.

**Research question:** Which regular-season team statistics are most
useful for predicting upsets in the NCAA Men’s Basketball Tournament?

For this project, an upset occurs when a team with a larger numerical
seed defeats a team with a smaller numerical seed.

## Planned Methods

- Clean and combine regular-season results, tournament results, and seeds.
- Calculate season-level statistics for each team.
- Compare the statistical profiles of opponents in tournament matchups.
- Use logistic regression to estimate the probability of an upset.
- Compare predictions with a model using tournament seeds alone.
- Evaluate performance on later seasons held out from model training.

## Potential Predictors

- Winning percentage
- Average scoring margin
- Field-goal and three-point percentages
- Free-throw percentage
- Rebounding statistics
- Turnovers and assist-to-turnover ratio

The final set of predictors will be determined through data exploration
and model evaluation.

## Data Source

Data comes from
[Kaggle’s March Machine Learning Mania 2026](https://www.kaggle.com/competitions/march-machine-learning-mania-2026/data).

The files selected for this project are:

- `MRegularSeasonDetailedResults.csv`
- `MNCAATourneyCompactResults.csv`
- `MNCAATourneySeeds.csv`
- `MTeams.csv`

## Tools

- R and RStudio for data preparation, analysis, and visualization
- GitHub for project documentation and version control

## Milestone 1 — Current Progress

I have selected my research question, discussed the project with my
faculty advisor, downloaded and initially examined the datasets, and
identified relevant background articles.

My next step is to combine the datasets and calculate regular-season
team statistics for use in the analysis.



## References

- [Dartmouth Sports Analytics: First-round upset indicators](https://sites.dartmouth.edu/sportsanalytics/2024/02/27/which-factors-can-indicate-and-give-foresight-to-major-first-round-upsets-in-the-mens-ncaa-tournament/)
- [Matt Worley: Predicting Upsets with Machine Learning](https://medium.com/data-science/predicting-upsets-in-the-ncaa-tournament-with-machine-learning-816fecf41f01)
- Dutta, S., Jacobson, S. H., & Sauppe, J. J. (2017).
  [Identifying NCAA tournament upsets using Balance Optimization Subset Selection](https://doi.org/10.1515/jqas-2016-0062).
  *Journal of Quantitative Analysis in Sports, 13*(2), 79–93.

## Author

Albert Blair  
Mathematics and Data Science  
University of Wisconsin–River Falls  
CIDS 488 — Senior Capstone, Fall 2026
