# Import libraries
library(ggplot2)
library(forcats)
library(scales)
library(dplyr)
library(DBI)

# Connect to database
con <- dbConnect(RSQLite::SQLite(), "res/survey_results.db")

# Return devtypes without nulls
devtypes <- dbGetQuery(con,
                       "SELECT DevType
                       FROM survey
                       WHERE DevType IS NOT NULL;")

# Preparate data
devtypes_split <- strsplit(devtypes$DevType, split = ";")

# Flatten list and convert to dataframe
devtypes_df <- as.data.frame(unlist(devtypes_split))
colnames(devtypes_df) <- colnames(devtypes)

# Sort by frequency of values in descending order
devtypes_df <- mutate(devtypes_df, DevType = fct_rev(fct_infreq(DevType))) 

# Plot data
ggplot(devtypes_df, aes(x = DevType)) +
  geom_bar(color = "#00a4a8", fill = "#00bfc4", width = 0.8) +
  coord_flip() +
  theme_minimal() +
  labs(title = "Developer Type",
       subtitle = lengths(devtypes) %>%
         format(big.mark = ".", decimal.mark = ",") %>%
         paste("All Respondents (", ., ")", sep = ""),
       y = "Amount") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title.y = element_blank()) +
  scale_y_continuous(limits = c(0, 46000), breaks = seq(0, 46000, 10000), expand = c(0,0), labels = scales::number_format(big.mark = ".", decimal.mark = ",")) +
  geom_text(aes(label = stat((count/lengths(devtypes)) %>% scales::percent(decimal.mark = ",", accuracy = 0.1))), stat = "count", hjust = -0.1)

# Disconnect database
dbDisconnect(con)

