library(ggplot2)
library(forcats)
library(scales)
library(dplyr)
library(reshape2)
library(DBI)
library(tidyr)
library(ggrepel) # https://github.com/slowkow/ggrepel

# Connect to database
con <- dbConnect(RSQLite::SQLite(), "res/survey_results.db")

# Get Information about Gender, Competence and Experience
yig <- dbGetQuery(con,
                    "SELECT YearsCodePro, ImpSyn, Gender
                    FROM survey
                    WHERE YearsCodePro IS NOT NULL
                    AND ImpSyn IS NOT NULL
                    AND Gender IS NOT NULL
                    AND (ImpSyn = 'A little above average'
                    OR ImpSyn = 'Far above average');") %>%
  as.data.frame()

# Get respondants of each gender
ga <- dbGetQuery(con,
                 "SELECT YearsCodePro, ImpSyn, Gender
                 FROM survey
                 WHERE YearsCodePro IS NOT NULL
                 AND ImpSyn IS NOT NULL
                 AND Gender IS NOT NULL;") %>%
  as.data.frame()

# Transform YearsCodePro into numbers
yig$YearsCodePro[yig$YearsCodePro == "Less than 1 year"] <- 0
yig$YearsCodePro[yig$YearsCodePro == "More than 50 years"] <- 50
yig <- transform(yig, YearsCodePro = as.numeric(YearsCodePro))

ga$YearsCodePro[ga$YearsCodePro == "Less than 1 year"] <- 0
ga$YearsCodePro[ga$YearsCodePro == "More than 50 years"] <- 50
ga <- transform(ga, YearsCodePro = as.numeric(YearsCodePro))

# Group genders
yig$Gender[yig$Gender != "Man" & yig$Gender != "Woman"] <- "Non-binary"
ga$Gender[ga$Gender != "Man" & ga$Gender != "Woman"] <- "Non-binary"

# Get Amounts
yig <- yig %>% group_by(YearsCodePro, Gender) %>% tally()
ga <- ga %>% group_by(YearsCodePro, Gender) %>% tally()

# Merge Amounts into new data frame
colnames(ga)[3] <- "N"
df <- merge(yig, ga, by.ga = "N", all=TRUE)
df <- df[complete.cases(df[ ,]),]

# Plot data
ggplot(df, aes(x = YearsCodePro, y = n/N, color = Gender)) +
  geom_smooth(aes(color = Gender), se=F, method = "loess", formula = "y ~ x") +
  labs(title = "Competence and Experience",
       subtitle = sum(ga$N) %>%
         format(big.mark = ".", decimal.mark = ",") %>%
         paste("All Respondents (", ., ")", sep = ""),
       x = "Years of coding experience",
       y = "% who consider themselves above average") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5)) +
  scale_y_continuous(limits = c(0.30, 1), breaks = seq(0.30, 1, 0.2), labels = scales::percent_format(big.mark = ".", decimal.mark = ",")) +
  scale_x_continuous(limits = c(0, 25), breaks = seq(0, 25, 5))

# Disconnect database
dbDisconnect(con)
