library(ggplot2)
library(forcats)
library(scales)
library(dplyr)
library(DBI)

# Connect to database
con <- dbConnect(RSQLite::SQLite(), "res/survey_results.db")

# Return hobbyist grouped by yes or no as dataframe
hobby_gender <- dbGetQuery(con,
                           "SELECT Gender, Hobbyist, COUNT(*) AS Amount
                           FROM survey
                           WHERE Hobbyist IS NOT NULL
                           AND Gender IS NOT NULL
                           GROUP BY Hobbyist, Gender
                           ORDER BY Amount DESC;") %>%
  as.data.frame()

# Combine diverse genders amount
others <- hobby_gender %>%
  slice(5:14) %>%
  group_by(Hobbyist) %>%
  summarise(Gender = "Others", Amount = sum(Amount), .groups = 'drop') %>%
  arrange(desc(Amount)) %>%
  relocate(Gender, .before = Hobbyist)

# Remove others from dataframe
hobby_gender <- hobby_gender[-c(5:14), ]

# Combine both dataframes
hobby_gender <- rbind(hobby_gender, others)

# Plot data
ggplot(hobby_gender, aes(factor(reorder(Gender, -Amount)), Amount, fill = fct_rev(Hobbyist))) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal() +
  scale_fill_manual("Hobbyist", values = c("Yes" = "#f8766d", "No" = "#00bfc4")) +
  labs(title = "Coding as a Hobby by Gender",
       subtitle = sum(hobby_gender$Amount) %>%
         format(big.mark = ".", decimal.mark = ",") %>%
         paste("All Respondents (", ., ")", sep = ""),
       fill = "Hobbyist") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title.x = element_blank()) +
  scale_y_continuous(limits = c(0, 68000), breaks = seq(0, 68000, 10000), expand = c(0, 0), labels = scales::number_format(big.mark = ".", decimal.mark = ",")) +
  geom_text(aes(label = (Amount/sum(Amount)) %>% scales::percent(decimal.mark = ",", accuracy = 0.1)), position = position_dodge(width = 0.9), vjust = -0.5)

# Disconnect database
dbDisconnect(con)
