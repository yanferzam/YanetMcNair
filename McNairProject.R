

#if package is not already installed, install it
if (!require("dplyr")) install.packages("dplyr")  
if (!require("stringr")) install.packages("stringr") 
if (!require("tidyr")) install.packages("tidyr")
if (!require("tidycensus")) install.packages("tidycensus")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("USAboundaries")) install.packages("USAboundaries")
if (!require("USAboundariesData")) install.packages("USAboundariesData ", repos = "https://ropensci.r-universe.dev", type = "source")
if (!require("usdata")) install.packages("usdata")

library(dplyr) 
library(stringr)
library(tidyr)
library(tidyverse)
library(tidycensus)
library(ggplot2)
library(USAboundariesData)
library(USAboundaries)
library(usdata)

census_api_key("8bf1a6a7e21b7fc1c29757c7cd31eb3684a47783", overwrite = TRUE, install = TRUE)
readRenviron("~/.Renviron")

#variables in census data from acs5 2020
v2020 <- load_variables(2020, "acs5")
View(v2020)

#identified desired variables to work with and map
district_pop <- get_acs(geography = "congressional district", 
                        variables = c(total.pop = "B01001_001",
                                      foreign.pop = "B05002_013",
                                      median.inc = "B19013_001",
                                      white.pop = "B02001_002"),
                        year = 2020,survey ="acs5",
                        output = "wide")

#extra vectors created to identify state id and congressional district id
#ST vector is not needed
state.cd_id <- district_pop %>%
  mutate(state_name = str_extract(NAME,"[^,]+$"))%>%
  mutate(cd = str_remove(GEOID, "\\d\\d")) %>% 
  mutate(ST = str_remove(GEOID, "\\d\\d$"))#not really needed

#this removes Alaska/Hawaii from census data
state.cd_id2 <- state.cd_id %>%
  filter(!str_detect(state_name, "Hawaii|Alaska")) %>%
  mutate(abb = state2abbr(state_name))

#congressional district map data 
cong.map <- us_congressional(resolution = "low")

# this removes Alaska/Hawaii from map data
cong.map <- filter(cong.map, state_name %in% state.name & !(state_name %in% c("Hawaii", "Alaska")))

## create vector for Districts, to line up with state.cd_id2 and tweet data
cong.map$District <- paste(cong.map$state_abbr, cong.map$cd116fp, sep = "")

# create vector for Districts, to line up with tweet data and cong.map 
state.cd_id2$District <- paste(state.cd_id2$abb, state.cd_id2$cd, sep = "")

#renamed vector to facilitate merging of tables(census data and map data)
state.cd_id2 <- state.cd_id2 %>% rename(stateNAME = state_name)

## merge mapping data with census data, joined by 'District'
immigration_pop <- full_join(cong.map, state.cd_id2)

#map foreign born population per congressional district
ggplot(data = immigration_pop, mapping = aes()) +
  geom_sf(aes(fill = foreign.popE)) +
  scale_fill_gradient2(low = ("white"),
                       mid = ("yellow"),
                       high = ("purple"),
                       midpoint = 2e+05,
                       na.value = "grey50") +
  theme(panel.background = element_blank(), plot.title = element_text(size = 10), legend.title = element_text(size = 5),plot.subtitle = element_text(size = 6),
        legend.key.size = unit(.7, "cm"), legend.text = element_text(size = 5) 
      ) +
  labs(title = "Foreign born population in the U.S. per congressional district", subtitle = "American Community Survey 5-Year Data (2016-2020)",
       fill = "population"  )

