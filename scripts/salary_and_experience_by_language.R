library(ggplot2)
library(scales)
library(dplyr)
library(DBI)
library(tidyr)
library(ggrepel) # https://github.com/slowkow/ggrepel

# Connect to database
con <- dbConnect(RSQLite::SQLite(), "res/survey_results.db")

# Get Information about Salary, Working experience and used Languages
saebl <- dbGetQuery(con,
                     "SELECT ConvertedComp, YearsCodePro, LanguageWorkedWith
                     FROM survey
                     WHERE ConvertedComp IS NOT NULL
                     AND YearsCodePro IS NOT NULL
                     AND LanguageWorkedWith IS NOT NULL;") %>%
  as.data.frame()

# Separate Languages
saebl_separated <- saebl %>% separate_rows(LanguageWorkedWith, sep = ";")

# Transform Coding experience column into numbers
saebl_separated$YearsCodePro[saebl_separated$YearsCodePro == "Less than 1 year"] <- 1
saebl_separated$YearsCodePro[saebl_separated$YearsCodePro == "More than 50 years"] <- 50
saebl_separated <- transform(saebl_separated, YearsCodePro = as.numeric(YearsCodePro))

# Get amount of respondents for each language
LanguagesCount <- saebl_separated %>% count(LanguageWorkedWith)

# Group by Languages and get median of Salary and average working experience
saebl_separated <- saebl_separated %>% group_by(LanguageWorkedWith) %>% summarise(medianConvertedComp = median(ConvertedComp), meanYearsCodePro = mean(YearsCodePro), .groups = 'drop')

# Join both dataframes
saebl_all<-cbind(saebl_separated, LanguagesCount[!names(LanguagesCount) %in% names(saebl_separated)])

# Remove "Other(s)" language from data
saebl_all <- subset(saebl_all, LanguageWorkedWith!="Other(s):")

# Plot data
ggplot(saebl_all, aes(x = meanYearsCodePro, y = medianConvertedComp, size = n)) +
  geom_smooth(method=lm , color="#5AA2F9", fill="#99c7ff", se=TRUE, show.legend = FALSE, formula = "y ~ x") +
  geom_point(alpha = 0.7, color = "#f8766d") +
  scale_size(range = c(1, 8), name="Number of respondents") +
  theme_minimal() +
  labs(title = "Salary and Experience by Language",
       subtitle = sum(saebl_all$n) %>%
         format(big.mark = ".", decimal.mark = ",") %>%
         paste("All Respondents (", length(saebl$LanguageWorkedWith) %>% format(big.mark = ".", decimal.mark = ","), "), Multiple answers given (", ., ")", sep = ""),
       x = "Average years of professional programming experience",
       y = "Median salary (USD)") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5)) +
  scale_y_continuous(
    limits = c(40000, 90000),
    breaks = seq(40000, 90000, 10000),
    labels = scales::number_format(big.mark = ".", decimal.mark = ",")) +
  geom_text_repel(label = saebl_all$LanguageWorkedWith, size = 3)

# Disconnect database
dbDisconnect(con)
