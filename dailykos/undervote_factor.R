### CALCULATES ELECTION RESULTS FOR GOVERNOR ###
### BROKEN DOWN BY STATE LEGISLATIVE DISTRICT ###

join_tidy <- read.csv("join_tidy.csv", stringsAsFactors = FALSE)

# list of split precincts in the state 
split_precinct_df <- join_tidy %>% 
  group_by(county,precinct) %>% 
  select(-c(house_candidate:gov_votes)) %>%
  distinct(county,precinct,house_district, .keep_all = TRUE) %>%
  filter(n()>1)

split_precincts <- sort(split_precinct_df[["precinct"]])

# total votes for the governor's race in a county's unsplit precincts
county_gov_unsplit_df <- join_tidy %>%
  group_by(county,house_district) %>% 
  select(-c(house_candidate:office)) %>%
  filter(gov_candidate == "precinct_total") %>%
  distinct() %>%
  filter(!precinct %in% split_precincts) %>%
  summarize(unsplit_gov_total = sum(as.numeric(gov_votes))) 

# total votes for the state house races in a county's unsplit precincts
county_house_unsplit_df <- join_tidy %>%
  group_by(county,house_district) %>% 
  filter(!precinct %in% split_precincts) %>%
  select(-c(office:gov_votes)) %>%
  distinct(precinct,house_candidate, .keep_all = TRUE) %>%
  summarize(unsplit_house_total = sum(as.numeric(house_votes))) 

# calculates undervote factor (house votes from unsplit precincts/gov votes from unsplit precincts)
undervote_df <- full_join(county_gov_unsplit_df,county_house_unsplit_df, 
                by=c("county","house_district")) %>%
  mutate(undervote_factor = unsplit_house_total/unsplit_gov_total) %>%
  arrange(county,house_district) %>%
  select(-c("unsplit_gov_total","unsplit_house_total")) %>%
  inner_join(split_precinct_df,undervote_df,
             by=c("county","house_district"))

# list of house votes for each district by precinct and county
ga_votes <- join_tidy %>% 
  select(-c(office:gov_votes)) %>%
  mutate_at(vars(house_votes),funs(as.numeric)) %>%
  group_by(county,precinct,house_district) %>%
  summarize(house_votes = sum(house_votes))
  
# calculates the undervote-adjusted hypothetical governor vote total 
# if there had been no undervoting in the state house races
hypothetical_df <- inner_join(ga_votes,undervote_df, by=c("county","precinct","house_district")) %>%
  mutate(hypo_gov_votes = as.numeric(house_votes/undervote_factor)) %>%
  group_by(county,precinct) %>%
  mutate(total = sum(hypo_gov_votes)) %>%
  mutate(vote_share = hypo_gov_votes / total)

# total votes for each governor candidate and precinct
gov_complete_df <- join_tidy %>%
  select(-c(house_district:office)) %>%
  distinct()

# calculates estimated votes for each candidate using the hypothetical vote total 
# by total actual votes
estimated_vote_df <- inner_join(hypothetical_df,gov_complete_df, by=c("county","precinct")) %>%
  mutate(estimated_gov_votes = vote_share*gov_votes)

### SUMMARY TABLE ###
complete_df <- full_join(estimated_vote_df,join_tidy, 
                      by = c("county", "precinct", "house_district", 
                             "house_votes", "gov_candidate", "gov_votes")) %>%
  select(county,precinct,house_district,gov_candidate,gov_votes,estimated_gov_votes) %>%
  distinct() %>%
  mutate(votes = case_when(!is.na(estimated_gov_votes) ~ estimated_gov_votes,
                           is.na(estimated_gov_votes) ~ as.numeric(gov_votes))) %>%
  distinct(county,precinct,house_district,gov_candidate,gov_votes, .keep_all = TRUE) %>%
  select(-c(gov_votes,estimated_gov_votes)) %>%
  spread(key=gov_candidate,value=votes) %>%
  group_by(county,house_district) %>%
  summarize(Cordray = sum(Cordray), 
            DeWine = sum(DeWine), 
            Total = sum(precinct_total)) %>%
  ungroup() %>%
  mutate(`Cordray%` = paste0(format(round(Cordray/Total*100,digits=2),nsmall=2),"%"),
         `DeWine%` = paste0(format(round(DeWine/Total*100,digits=2),nsmall=2),"%")) %>%
  mutate(ShortName = ifelse(county %in% county[duplicated(county)],paste(county,"(sp.)"),county)) %>%
  select(house_district,ShortName,Cordray,DeWine,Total,`Cordray%`,`DeWine%`) %>%
  arrange(house_district) %>%
  mutate(house_district = as.character(house_district)) %>%
  bind_rows(summarise_all(., funs(if(is.numeric(.)) sum(.) else "Total"))) %>%
  rename(HD = "house_district") %>%
  mutate(ShortName = replace(ShortName, n(), ""),
         `Cordray%` = replace(`Cordray%`,n(), (Cordray/Total*100)[n()]),
         `DeWine%` = replace(`DeWine%`,n(), (DeWine/Total*100)[n()])) %>%
  mutate(Cordray = round(Cordray),
         DeWine = round(DeWine),
         Total = round(Total), 
         `Cordray%` = replace(`Cordray%`,n(), paste0(round(as.numeric(`Cordray%`[n()]),digits=2),"%")),
         `DeWine%` = replace(`DeWine%`,n(), paste0(round(as.numeric(`DeWine%`[n()]),digits=2),"%")))

write.csv(complete_df, file="ohio_2018_results.csv", row.names = F)
