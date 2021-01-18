library(ggplot2)
library(scales)
library(dplyr)
library(DBI)

# Connect to database
con <- dbConnect(RSQLite::SQLite(), "res/survey_results.db")

# Return hobbyist grouped by yes or no as dataframe
hobbyist <- dbGetQuery(con,
                          "SELECT Hobbyist, COUNT(*) AS Amount
                          FROM survey
                          WHERE Hobbyist IS NOT NULL
                          GROUP BY Hobbyist
                          ORDER BY Amount DESC;") %>%
  as.data.frame()

# add Percentage and position of labels
hobbyist <- hobbyist %>%
  mutate(prop = hobbyist$Amount / sum(hobbyist$Amount) * 100) %>%
  mutate(ypos = cumsum(prop) - 0.5*prop)

# Plot data
ggplot(hobbyist, aes(x = "", y = prop, fill = Hobbyist)) + 
  geom_bar(stat="identity", width = 1, color = "white") + 
  coord_polar("y", start = 0) +
  theme_void() + 
  labs(title = "Coding as a Hobby",
       subtitle = sum(hobbyist$Amount) %>%
         format(big.mark = ".", decimal.mark = ",") %>%
         paste("All Respondents (", ., ")", sep = "")) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5)) +
  geom_text(aes(y = ypos, label = prop %>% format(digits = 3, decimal.mark = ",") %>% paste("%", sep = "")), color = "white", size = 6)

# Disconnect database
dbDisconnect(con)
