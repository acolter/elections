library(tidyr)
library(dplyr)

## General Election Clackamas County Oregon November 2006

file <- "Clackamas - State House 52.csv"
df <- clean_file(file)

clean_file <- function(file) {
df <- read.csv(file, stringsAsFactors = FALSE)

## update values for office and district from file
office <- paste(unlist(strsplit(file," "))[3],unlist(strsplit(file," "))[4])
district <- regmatches(file, regexpr("[[:digit:]]+", file)) #could be "[0-9]+" or \\d+
candidate <- tail(names(df),-1)
county <- regmatches(file, regexpr("[[:alpha:]]+", file))

df <- df %>% 
  gather(candidate, key = candidate, value = votes) %>%
  separate(candidate, sep = "\\.{2,}", into = c("candidate","party")) %>%
  mutate(county = county, 
         office = office, 
         district = district) %>%
  select(county,precinct,office,district,party,candidate,votes)

## clean up errant periods and NA values
df$candidate <- gsub('[\\.]', ' ', df$candidate)
df$party <- gsub('[.]$', ' ', df$party)
df[is.na(df)] <- ""
write.csv(df, file="clackamas.csv", row.names = F)

return(df)

}

