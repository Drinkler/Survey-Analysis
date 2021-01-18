library(rworldmap)
library(ggplot2)
library(DBI)

# Connect to database
con <- dbConnect(RSQLite::SQLite(), "res/survey_results.db")

# Return countries with number of participants
respondents <- dbGetQuery(con, 
                        "SELECT Country, COUNT(*) AS 'Number of participants'
                        FROM survey
                        WHERE Country IS NOT NULL
                        GROUP BY Country
                        ORDER BY 'Number of participants' DESC;")

# Convert to dataframe
respondents_df <- as.data.frame(respondents)

# Add percentage
responses <- sum(respondents_df[["Number of participants"]])
respondents_df[["percentage"]] <- (respondents_df[["Number of participants"]] / responses * 100) %>% round(2)

# Convert countries to an internal map, used for plotting
sPDF <- joinCountryData2Map(respondents_df,
                            joinCode = "NAME",
                            nameJoinColumn = "Country")

# Plot map
mapBubbles(dF = sPDF,
           nameZSize = "percentage",
           nameZColour = adjustcolor("#00bfc4", alpha.f = 0.6),
           legendPos = "bottomleft",
           landCol = "#F5F5F5",
           addLegend = TRUE )
mtext("Survey Respondents in Percent",side=3,line=-0.5)

# Disconnect database
dbDisconnect(con)
