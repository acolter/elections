library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(zoo)

file <- "2018-11-06_statewideprecinct_miami.xlsx"
excel_sheets(file)

## governor results
df <- read_xlsx(file, sheet=3, skip=1, col_names=TRUE)
gov_tidy <- df %>% 
  select(c(1,2,9:15)) %>%
  slice(-c(1:2)) %>% 
  mutate(precinct_total = rowSums(.[3:9])) %>%
  select(-c(3,6:9)) %>%
  mutate(office = "governor") %>%
  rename(county = "County Name",
         precinct = "Precinct Name",
         Cordray = "Richard Cordray and Betty Sutton (D)",
         DeWine = "Mike DeWine and Jon Husted (R)") %>%
  gather(key = gov_candidate, value = gov_votes, Cordray:precinct_total)

write.csv(gov_tidy, file=("gov_tidy.csv"), row.names = F)

## state legislative results
df <- read_xlsx(file, sheet=5, col_names = FALSE)
df[1,] <- paste(na.locf(as.character(df[1,])), df[2,], sep="-")
df[1,1:2] <- c("county","precinct")

ga_tidy <- df %>%
  select(-c(3:44)) %>%
  slice(-c(2:4)) %>%
  mutate_all(funs(str_replace(., "State Representative - District ", "")))  

colnames(ga_tidy) <- ga_tidy[1,]
house_candidate <- tail(names(ga_tidy),-2)

ga_tidy <- ga_tidy %>% 
  slice(-1) %>% 
  gather(house_candidate, key = house_candidate, value = house_votes) %>%
  separate(house_candidate, sep = 3, into = c("house_district","house_candidate")) %>%
  mutate(house_district = str_replace(house_district, "-","")) %>%
  mutate(house_votes = na_if(house_votes, "0")) %>%
  mutate_at(vars(5), as.numeric) %>%
  drop_na()

write.csv(ga_tidy, file=("ga_tidy.csv"), row.names = F)

## join the two sheets
join_tidy <- full_join(ga_tidy,gov_tidy,by=c("county","precinct"))
write.csv(join_tidy, file=("join_tidy.csv"), row.names = F)
