library(ggplot2)
library(forcats)
library(scales)
library(dplyr)
library(reshape2)
library(DBI)

# Connect to database
con <- dbConnect(RSQLite::SQLite(), "res/survey_results.db")

# Return JobSat grouped as dataframe
jobsat <- dbGetQuery(con,
                     "SELECT JobSat, COUNT(*) AS Job
                     FROM survey
                     WHERE JobSat IS NOT NULL
                     GROUP BY JobSat
                     ORDER BY Job DESC;") %>%
  as.data.frame()

# Return CareerSat grouped as dataframe
carsat <- dbGetQuery(con,
                     "SELECT CareerSat, COUNT(*) AS Career
                     FROM survey
                     WHERE CareerSat IS NOT NULL
                     GROUP BY CareerSat
                     ORDER BY Career DESC;") %>%
  as.data.frame()

# Reorder x-axis
jobsat$JobSat <- fct_rev(factor(jobsat$JobSat, levels = c("Very dissatisfied", "Slightly dissatisfied", "Neither satisfied nor dissatisfied", "Slightly satisfied", "Very satisfied")))
carsat$CareerSat <- fct_rev(factor(carsat$CareerSat, levels = c("Very dissatisfied", "Slightly dissatisfied", "Neither satisfied nor dissatisfied", "Slightly satisfied", "Very satisfied")))

# Combine both dataframes
satisfaction <- cbind(jobsat, carsat %>% select(Career))

# Get sums for subtitle
jobsum <- sum(satisfaction$Job) %>% format(big.mark = ".", decimal.mark = ",")
careersum <- sum(satisfaction$Career) %>% format(big.mark = ".", decimal.mark = ",")

# Plot data
ggplot(melt(satisfaction, id.vars = "JobSat"), aes(x = JobSat, y = value, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge")+
  coord_flip() +
  theme_minimal() +
  scale_fill_manual("Satisfaction", values = c("Job" = "#f8766d", "Career" = "#00bfc4")) +
  labs(title = "Job and Career Satisfaction",
       subtitle = paste("All Respondents (Job: ", jobsum, ", Career: ", careersum, ")", sep = ""),
       y = "Amount") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title.y = element_blank()) +
  scale_y_continuous(limits = c(0, 32500), breaks = seq(0, 32500, 5000), expand = c(0, 0), labels = scales::number_format(big.mark = ".", decimal.mark = ",")) +
  geom_text(aes(label = value %>% format(big.mark=".", decimal.mark=",")), hjust = -0.1, position = position_dodge(width = 1))

# Disconnect database
dbDisconnect(con)
