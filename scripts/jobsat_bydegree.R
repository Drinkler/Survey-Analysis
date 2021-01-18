library(ggplot2)
library(forcats)
library(scales)
library(dplyr)
library(reshape2)
library(DBI)

# Connect to database
con <- dbConnect(RSQLite::SQLite(), "res/survey_results.db")

# Return JobSat by degree grouped as dataframe
jobsat_by_degree <- dbGetQuery(con,
                     "SELECT JobSat, EdLevel, COUNT(*) AS Amount
                     FROM survey
                     WHERE JobSat IS NOT NULL
                     AND EdLevel IS NOT NULL
                     GROUP BY JobSat, EdLevel;") %>%
  as.data.frame()

jobsat_by_degree$JobSat <- factor(jobsat_by_degree$JobSat, levels = c("Very dissatisfied", "Slightly dissatisfied", "Neither satisfied nor dissatisfied", "Slightly satisfied", "Very satisfied"))

ggplot(jobsat_by_degree, aes(fill = EdLevel, x = JobSat, y = Amount)) +
  geom_bar(position = "stack", stat = "identity") +
  theme_minimal() +
  scale_fill_discrete(name = "Education Level") +
  labs(title = "Job Satisfaction by Education Level",
       subtitle = paste("All Respondents (Job: ", sum(jobsat_by_degree$Amount) %>% format(big.mark = ".", decimal.mark = ","), ")", sep = ""),
       y = "Percentage") +
  theme(axis.text.x = element_text(angle=90, vjust=0.3, hjust=1),
        plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title.x = element_blank())

# Disconnect database
dbDisconnect(con)

