library(ggplot2)
library(forcats)
library(scales)
library(dplyr)
library(reshape2)
library(DBI)
library(packcircles)

# Connect to database
con <- dbConnect(RSQLite::SQLite(), "res/survey_results.db")

# Return Development Environments
devEnviron <- dbGetQuery(con,
                         "SELECT DevEnviron
                         FROM survey
                         WHERE DevEnviron IS NOT NULL;") %>%
  as.data.frame()

# Get amount of respondents
respondents <- length(devEnviron$DevEnviron) %>%
  format(big.mark = ".", decimal.mark = ",")

# Subtract data from query
singleDevEnviron <- strsplit(devEnviron$DevEnviron, split = ";") %>%
  unlist() %>%
  as.data.frame()

# Rename column
names(singleDevEnviron)[1] <- "devEnviron"

# Group dev Environments and get amount
devEnviron <- singleDevEnviron %>% group_by(devEnviron) %>% tally() 

# Generate the layout. This function return a dataframe with one line per bubble. It gives its center (x and y) and its radius, proportional of the value
packing <- circleProgressiveLayout(devEnviron$n, sizetype = "area")

# Add the packing information to the initial data frame
devEnviron <- cbind(devEnviron, packing)

# The next step is to go from one center + a radius to the coordinates of a circle that is drawn by a multitude of straight lines.
devEnviron.gg <- circleLayoutVertices(packing, npoints = 50)

# Plot data
ggplot() +
  geom_polygon(data = devEnviron.gg, aes(x, y, group = id, fill=as.factor(id)), colour = "black", alpha = 0.6) +
  geom_text(data = devEnviron, aes(x, y, size = n, label = devEnviron)) +
  scale_size_continuous(rang = c(1,4)) +
  labs(title = "Development Environments",
       subtitle = sum(devEnviron$n) %>%
         format(big.mark = ".", decimal.mark = ",") %>%
         paste("All Respondents (", respondents, "), Multiple answers given (", ., ")", sep = "")) +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        legend.position = "none") +
  coord_equal()

# Disconnect database
dbDisconnect(con)
