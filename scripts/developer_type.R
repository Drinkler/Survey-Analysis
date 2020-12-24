# Import libraries
library(ggplot2)
library(forcats)
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
devtypes_split <- strsplit(devtypes$DevType, split  = ";")

# Flatten list and convert to dataframe
devtypes_df <- as.data.frame(unlist(devtypes_split))
colnames(devtypes_df) <- colnames(devtypes)

# Sort by frequency of values in descending order
devtypes_df <- mutate(devtypes_df, DevType = fct_rev(fct_infreq(DevType))) 

# Plot data
ggplot(devtypes_df, aes(x = DevType)) +
  geom_bar(color = "#5AA2F9", fill = "#8BBEFB", width = 0.8) +
  coord_flip() +
  labs(title = "Developer Type",
       subtitle = lengths(devtypes) %>%
         format(big.mark = ".", decimal.mark = ",") %>%
         paste("All Respondents (", ., ")", sep = ""),
       y = "Amount") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title.y = element_blank()) +
  scale_y_continuous(limits = c(0, 45000), breaks = seq(0, 45000, 10000)) +
  geom_text(aes(label = stat((count/lengths(devtypes)*100) %>%
                               round(1) %>%
                               format(decimal.mark = ",") %>% 
                               paste("%", sep = ""))), stat = "count", hjust = -0.1)
#paste("All Respondents (" , format(lengths(devtypes), big.mark=".", decimal.mark = ",") , ")", sep="")
#geom_text(aes(label=stat(paste(format(round(count/lengths(devtypes)*100, 1), decimal.mark = ","), "%", sep=""))), stat="count", hjust=-0.1)

# Disconnect database
dbDisconnect(con)

