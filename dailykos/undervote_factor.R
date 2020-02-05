## unsplit totals for gov and house

join_tidy <- read.csv("join_tidy.csv", stringsAsFactors = FALSE)

### UNADJUSTED NUMBERS FOR COUNTY TABS ###
county_tab_df <- join_tidy %>%
  select(-c(house_candidate:office)) %>%
  distinct() %>%
  spread(key=gov_candidate,value=gov_votes) 

by_county <- split(county_tab_df,county_tab_df$county)
sapply(names(by_county), 
       function (x) write.csv(by_county[[x]], file=paste0("counties/",x,".csv"), row.names=FALSE))

## unadjusted numbers for gov race ##
gov_complete_df <- join_tidy %>%
  select(-c(house_district:office)) %>%
  distinct()


### UNSPLIT PRECINCTS FOR TABLE TAB ###

## list of split precincts 
split_precinct_df <- join_tidy %>% 
  group_by(county,precinct) %>% 
  select(-c(house_candidate:gov_votes)) %>%
  distinct(county,precinct,house_district, .keep_all = TRUE) %>%
  filter(n()>1)

## There are 255 split precincts in 21 counties 
split_precincts <- sort(split_precinct_df[["precinct"]])
split_precincts_counties <- sort(unique(split_precinct_df[["county"]]))

## calculates governor votes in unsplit precincts
gov_unsplit_df <- join_tidy %>% 
  select(-c(house_candidate,office)) %>%
  distinct(county,precinct,house_district,gov_candidate,gov_votes) %>%
  mutate(gov_votes = ifelse(precinct %in% split_precincts, NA, gov_votes)) %>%
  spread(key=gov_candidate,value=gov_votes) %>%
  group_by(county,house_district) %>%
  summarize(Cordray = sum(Cordray), 
            DeWine = sum(DeWine), 
            Total = sum(precinct_total)) %>%
  mutate(ShortName = ifelse(county %in% county[duplicated(county)],paste(county,"(sp.)"),county)) %>%
  rename(County = "county",
         HD = "house_district") %>%
  select(County,ShortName,HD,Cordray,DeWine,Total) 

write.csv(gov_unsplit_df, file="table_tab_unsplit.csv", row.names = F)


### SPLIT COUNTIES ###
county_gov_unsplit_df <- join_tidy %>%
  group_by(county,house_district) %>% 
  select(-c(house_candidate:office)) %>%
  filter(gov_candidate == "precinct_total") %>%
  distinct() %>%
  filter(!precinct %in% split_precincts) %>%
  summarize(unsplit_gov_total = sum(as.numeric(gov_votes))) 

county_house_unsplit_df <- join_tidy %>%
  group_by(county,house_district) %>% 
  filter(!precinct %in% split_precincts) %>%
  select(-c(office:gov_votes)) %>%
  distinct(precinct,house_candidate, .keep_all = TRUE) %>%
  summarize(unsplit_house_total = sum(as.numeric(house_votes))) 

undervote_df <- full_join(county_gov_unsplit_df,county_house_unsplit_df, 
                by=c("county","house_district")) %>%
  mutate(undervote_factor = unsplit_house_total/unsplit_gov_total) %>%
  arrange(county,house_district) %>%
  select(-c("unsplit_gov_total","unsplit_house_total")) %>%
  inner_join(split_precinct_df,undervote_df,
             by=c("county","house_district"))

ga_votes <- join_tidy %>% 
  select(-c(office:gov_votes)) %>%
  mutate_at(vars(house_votes),funs(as.numeric)) %>%
  group_by(county,precinct,house_district) %>%
  summarize(house_votes = sum(house_votes))
  
hypothetical_df <- inner_join(ga_votes,undervote_df, by=c("county","precinct","house_district")) %>%
  mutate(hypo_gov_votes = as.integer(house_votes/undervote_factor)) %>%
  group_by(county,precinct) %>%
  mutate(total = sum(hypo_gov_votes)) %>%
  mutate(vote_share = hypo_gov_votes / total)

estimated_vote_df <- inner_join(hypothetical_df,gov_complete_df, 
                              by=c("county","precinct")) %>%
  mutate(estimated_gov_votes = round(vote_share*gov_votes))

### ADJUSTED NUMBERS TO ADD TO COUNTY TABS ###
county_tabs_split <- estimated_vote_df %>%
  select(-c(house_votes:vote_share,gov_votes)) %>%
  spread(key=gov_candidate,value=estimated_gov_votes)

write.csv(county_tabs_split, file="county_tabs_split.csv", row.names = F)

### SUMMARY TABLE ###
complete_df <- full_join(estimated_vote_df,join_tidy, 
                      by = c("county", "precinct", "house_district", "house_votes", "gov_candidate", "gov_votes"))

by_county <- split(county_tabs_split,county_tabs_split$county)
sapply(names(by_county), 
       function (x) write.csv(by_county[[x]], file=paste0("counties/",x,"_split.csv"), row.names=FALSE))

complete_df <- complete_df %>%  
  select(county,precinct,house_district,gov_candidate,gov_votes,estimated_gov_votes) %>%
  distinct() %>%
  mutate_at(vars(gov_votes),funs(as.numeric)) %>%
  mutate(votes = case_when(!is.na(estimated_gov_votes) ~ estimated_gov_votes,
                           is.na(estimated_gov_votes) ~ gov_votes)) %>%
  distinct(county,precinct,house_district,gov_candidate,gov_votes, .keep_all = TRUE) %>%
  select(-c(gov_votes,estimated_gov_votes)) %>%
  spread(key=gov_candidate,value=votes) %>%
  group_by(county,house_district) %>%
  summarize(Cordray = sum(Cordray), 
            DeWine = sum(DeWine), 
            Total = sum(precinct_total)) %>%
  ungroup() %>%
  mutate(`Cordray%` = paste0(format(round(Cordray/Total*100,2),nsmall=2),"%"),
         `DeWine%` = paste0(format(round(DeWine/Total*100,2),nsmall=2),"%")) %>%
  mutate(ShortName = ifelse(county %in% county[duplicated(county)],paste(county,"(sp.)"),county)) %>%
  select(house_district,ShortName,Cordray,DeWine,Total,`Cordray%`,`DeWine%`) %>%
  rename(HD = "house_district") %>%
  arrange(HD)

write.csv(complete_df, file="ohio_2018_results.csv", row.names = F)
