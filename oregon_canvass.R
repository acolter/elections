library(tidyr)
library(dplyr)
library(stringr)

file <- "2000 Clackamas General - State Senate 28.csv"

tidy_data <- function(file) {

## read in the data but don't require the headers to be valid column names
## use the second row for the column names and get rid of the first row
df <- read.csv(file, stringsAsFactors = FALSE, header = FALSE)
colnames(df) <- df[1,]

## read in values for office, district and county from file name
office_pattern <- "President|U.S. |Secretary of |State |House|Senate|Governor|Attorney General| Treasurer"
office <- paste(str_extract_all(file, office_pattern, simplify = TRUE), collapse="")

string <- file %>%
  str_match("(\\d+)(-R)*.csv")
district <- string[,2]
candidate <- tail(names(df),-1)
county <- word(file,2)

## reshape wide format to long format
df <- df %>% 
  filter(row_number() != 1) %>%
  gather(candidate, key = candidate, value = votes) %>%
  separate(candidate, sep = -5, into = c("candidate","party")) %>%
  mutate(county = county, 
         office = office, 
         district = district,
         party = party) %>%
  select(county,precinct,office,district,party,candidate,votes) 

## clean up errant periods and NA values
df$party <- str_remove(df$party, "\\)")
df$party <- str_remove(df$party, "\\(")
df[is.na(df)] <- ""
write.csv(df, file=paste0(county,".csv"), row.names = F)

return(df)

}

df <- tidy_data(file)
