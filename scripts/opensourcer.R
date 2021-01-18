library(ggplot2)
library(scales)
library(dplyr)
library(DBI)

# Connect to database
con <- dbConnect(RSQLite::SQLite(), "res/survey_results.db")

# Return countries with number of participants
opensourcer <- dbGetQuery(con,
                          "SELECT OpenSourcer, COUNT(*) AS Amount
                          FROM survey
                          WHERE OpenSourcer IS NOT NULL
                          GROUP BY OpenSourcer
                          ORDER BY Amount DESC;")

# Convert to dataframe
opensourcer_df <- as.data.frame(opensourcer)

# Plot data
ggplot(opensourcer_df, aes(x = reorder(OpenSourcer, Amount), y = Amount)) +
  geom_bar(stat = "identity", color = "#00a4a8", fill = "#00bfc4", width = 0.8) + 
  coord_flip() + 
  theme_minimal() +
  labs(title = "Contributing to Open Source",
       subtitle = sum(opensourcer_df$Amount) %>%
         format(big.mark = ".", decimal.mark = ",") %>%
         paste("All Respondents (", ., ")", sep = "")) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title.y = element_blank()) +
  scale_y_continuous(limits = c(0, 35000), breaks = seq(0, 35000, 10000), expand = c(0, 0), labels = scales::number_format(big.mark = ".", decimal.mark = ",")) +
  geom_text(aes(label = (Amount/sum(Amount)) %>% scales::percent(decimal.mark = ",", accuracy = 0.1)), hjust = -0.1)

# Disconnect database
dbDisconnect(con)
