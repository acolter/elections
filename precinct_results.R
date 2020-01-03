## Cleaning output of numbered key canvass election results report 
## read in the data but don't require the headers to be valid column names
## use the second row for the column names and get rid of the first row

library(tidyr)
library(dplyr)
library(stringr)

file <- "2000 Clackamas General - State Senate 28.csv"

tidy_data <- function(file) {
df <- read.csv(file, stringsAsFactors = FALSE, header = FALSE)

## set column and variable names
colnames(df) <- df[1,]
offices <- "President|U.S. |Secretary of State|State Treasurer|State |House|Senate|Governor|Attorney General"
county <- word(file,2)
office <- paste(str_extract_all(file, offices, simplify = TRUE), collapse="")
district <- str_match(file,"(\\d+)(-R)*.csv")[,2]
candidate <- tail(names(df),-1)

## reshape wide format to long format
df <- df %>% 
  filter(row_number() != 1) %>%
  gather(candidate, key = candidate, value = votes) %>%
  separate(candidate, sep = -5, into = c("candidate","party")) %>%
  mutate(county = county, 
         office = office, 
         district = district,
         party = party) %>%
  mutate(district = replace_na(district, "")) %>%
  mutate(party = str_replace_all(party, "\\(|\\)","")) %>%
  mutate(candidate = str_replace(candidate, "\\s$","")) %>%
  select(county, precinct, office, district, party, candidate, votes) 
  
write.csv(df, file=paste0(county,".csv"), row.names = F)
return(df)

}

df <- tidy_data(file)
