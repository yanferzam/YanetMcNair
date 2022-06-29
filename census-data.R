#metadata = read.csv(file.choose())
data = read.csv(file.choose())

if (!require("dplyr")) install.packages("dplyr") #if package is not already installed, install it
if (!require("stringr")) install.packages("stringr") #if package is not already installed, install it
if (!require("tidyr")) install.packages("tidyr") #if package is not already installed, install it

library(dplyr) #call the package "dplyr"
library(stringr)#call the package "stringr"
library(tidyr)#call the package "tidyr"

#delete all columns that aren't estimate columns
#use pattern to determine which aren't estimate cols

data %>% 
  select(ends_with("E"))

# rename columns
rename(data, D01AE = DP02_0001M)

