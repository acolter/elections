## unsplit totals for gov and house

join_tidy <- read.csv("join_tidy.csv", stringsAsFactors = FALSE)
join_tidy <- mutate_at(join_tidy,vars(house_district),funs(as.character))
ga_tidy <- read.csv("ga_tidy.csv", stringsAsFactors = FALSE)

county_tabs <- join_tidy %>%
  select(-c(house_candidate:office)) %>%
  distinct() %>%
  spread(key=gov_candidate,value=gov_votes)

write.csv(county_tabs, file="county_tabs.csv", row.names = F)

split_precinct <- join_tidy %>% 
  mutate_at(vars(gov_votes,house_votes),funs(as.numeric)) %>%
  #mutate_at(vars(house_district),funs(as.character)) %>%
  group_by(county,precinct) %>% 
  select(-c(4:8)) %>%
  distinct(county,precinct,house_district, .keep_all = TRUE) %>%
  filter(n()>1) %>%
  arrange(desc(precinct), .by_group = TRUE)

## There are 255 split precincts in Ohio 
split_precincts <- split_precinct[["precinct"]]

### calculates governor votes in unsplit precincts 
gov_unsplit <- join_tidy %>% 
  select(-c(house_candidate,office)) %>%
  distinct(county,precinct,house_district,gov_candidate,gov_votes) %>%
  mutate(gov_votes = ifelse(precinct %in% split_precincts, NA, gov_votes)) %>%
  spread(key=gov_candidate,value=gov_votes) %>%
  group_by(county,house_district) %>%
  summarize(total_cordray = sum(Cordray), 
            total_dewine = sum(DeWine), 
            total_precinct = sum(precinct_total))

gov_unsplit_export <- gov_unsplit %>%
  mutate(shortname = ifelse(is.na(total_precinct),paste(county,"(sp.)"),county)) %>%
  rename(County = "county",
         ShortName = "shortname",
         HD = "house_district",
         Cordray = "total_cordray",
         DeWine = "total_dewine",
         Total = "total_precinct") %>%
  select(County,ShortName,HD,Cordray,DeWine,Total)

### import to TABLE TAB
write.csv(gov_unsplit_export, file="table_tab_unsplit.csv", row.names = F)

county_gov_unsplit <- join_tidy %>%
  group_by(county,house_district) %>% 
  select(-c(house_candidate:office)) %>%
  filter(gov_candidate != "Cordray" & gov_candidate != "DeWine") %>%
  distinct() %>%
  filter(!precinct %in% split_precincts) %>%
  summarize(unsplit_gov_total = sum(as.numeric(gov_votes)))

county_house_unsplit <- join_tidy %>%
  group_by(county,house_district) %>% 
  filter(!precinct %in% split_precincts) %>%
  select(-c(office:gov_votes)) %>%
  distinct(precinct,house_candidate, .keep_all = TRUE) %>%
  summarize(unsplit_house_total = sum(as.numeric(house_votes)))

uf <- full_join(county_gov_unsplit,county_house_unsplit, 
                by=c("county","house_district"))
uf <- uf %>%
  mutate(undervote_factor = unsplit_house_total/unsplit_gov_total) %>%
  arrange(county,house_district) %>%
  select(-c("unsplit_gov_total","unsplit_house_total")) %>%
  mutate_at(2, as.character)

split_precinct <- join_tidy %>% 
  group_by(county,precinct) %>% 
  select(-c(4:8)) %>%
  distinct(county,precinct,house_district, .keep_all = TRUE) %>%
  filter(n()>1) %>%
  arrange(desc(precinct), .by_group = TRUE) 

split_precinct_uf <- inner_join(split_precinct,uf,
                                   by=c("county","house_district"))

ga_votes <- ga_tidy %>% #from ohio_tidy2.R
  mutate_at(vars(house_votes),funs(as.numeric)) %>%
  mutate_at(vars(house_district),funs(as.character)) %>%
  group_by(county,precinct,house_district) %>%
  summarize(house_votes = sum(house_votes))
  
hypothetical <- inner_join(ga_votes,split_precinct_uf,
                                   by=c("county","precinct","house_district"))
hypothetical <- hypothetical %>%
  mutate(hypo_gov_votes = as.integer(house_votes/undervote_factor)) %>%
  group_by(county,precinct) %>%
  mutate(total = sum(hypo_gov_votes)) %>%
  mutate(vote_share = hypo_gov_votes / total)

gov_complete <- join_tidy %>%
  select(-c(house_district:office)) %>%
  distinct()

estimated_total <- inner_join(hypothetical,gov_complete, 
                              by=c("county","precinct"))

estimated_total<- estimated_total %>%
  mutate(estimated_gov_votes = round(vote_share*gov_votes))

## EXPORT THIS
county_tabs_split <- estimated_total %>%
  select(-c(house_votes:vote_share,gov_votes)) %>%
  spread(key=gov_candidate,value=estimated_gov_votes)

write.csv(county_tabs_split, file="county_tabs_split.csv", row.names = F)

complete <- full_join(estimated_total,join_tidy, 
                      by = c("county", "precinct", "house_district", "house_votes", "gov_candidate", "gov_votes"))
complete <- complete %>%  
  select("county","precinct","house_district","gov_candidate","gov_votes","estimated_gov_votes") %>%
  distinct() %>%
  mutate_at(vars(gov_votes),funs(as.numeric)) %>%
  mutate(votes = case_when(!is.na(estimated_gov_votes) ~ estimated_gov_votes,
                           is.na(estimated_gov_votes) ~ gov_votes)) %>%
  distinct(county,precinct,house_district,gov_candidate,gov_votes, .keep_all = TRUE) %>%
  select(-c("gov_votes","estimated_gov_votes")) %>%
  spread(key=gov_candidate,value=votes) %>%
  group_by(county,house_district) %>%
  summarize(total_cordray = sum(Cordray), 
            total_dewine = sum(DeWine), 
            total_precinct = sum(precinct_total)) %>%
  ungroup() %>%
  mutate(cordray_percent = total_cordray/total_precinct,
         dewine_percent = total_dewine/total_precinct) %>%
  select(house_district,county,total_cordray,total_dewine,total_precinct,cordray_percent,dewine_percent) %>%
  rename(HD = "house_district",
         County = "county",
         Cordray = "total_cordray",
         DeWine = "total_dewine",
         Total = "total_precinct",
         `Cordray%`= "cordray_percent",
         `DeWine%` = "dewine_percent")

write.csv(complete, file="complete_splits.csv", row.names = F)
