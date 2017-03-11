install.packages("tidyr")
library(tidyr)
library(reshape2)

file <- "2016 Ontario County, NY precinct-level election results - Contest overview.csv"
county <- "Ontario"

# Read in the whole file, figure out where the race you want starts
df <- read.csv(file, stringsAsFactors = FALSE)

# President
# Read in the race you want
pres_df <- read.csv(file, skip=8, nrows = 94, stringsAsFactors = FALSE)

# Drop the empty column
pres_df[,11] <- NULL

# Take data in wide format and stacks a set of columns into a single column of data 
pres_df2 <- melt(pres_df, id="ED")

# Split the candidate and party value into two columns
pres_df2 <- pres_df2 %>%
  separate(variable, c("candidate", "party"), "\\.{3,}")

# Rename and rearrange stuff
pres_df2$county <- county
pres_df2$office <- "President"
pres_df2$district <- NA
pres_df2 <- pres_df2[,c(5,1,6,7,3,2,4)]
colnames(pres_df2)[2] <- "precinct"
colnames(pres_df2)[7] <- "votes"

# Replace . separator with space
pres_df2$candidate <- gsub("\\.{1,}", " ", pres_df2$candidate)
pres_df2[pres_df2 == "Write in"] <- "Write-in"

# Write to a csv file
write.csv(pres_df2, file="ont_president.csv", row.names = F)

# U.S. Senate
ussen_df <- read.csv("2016 Montgomery County, NY precinct-level election results - Overview.csv", 
                    skip=55, nrows = 43, stringsAsFactors = FALSE)
#ussen_df[,11] <- NULL
ussen_df2 <- melt(ussen_df, id="ED")

ussen_df2 <- ussen_df2 %>%
  separate(variable, c("candidate", "party"), "\\.{3,}")

ussen_df2$county <- county
ussen_df2$office <- "U.S. Senate"
ussen_df2$district <- NA
ussen_df2 <- ussen_df2[,c(5,1,6,7,3,2,4)]
colnames(ussen_df2)[2] <- "precinct"
colnames(ussen_df2)[7] <- "votes"

ussen_df2$candidate <- gsub("\\.{1,}", " ", ussen_df2$candidate)
ussen_df2[ussen_df2 == "Write in"] <- "Write-in"

write.csv(ussen_df2, file="ont_ussenate.csv", row.names = F)

# U.S. House 23
usrep23_df <- read.csv(file, skip=302, nrows = 42, stringsAsFactors = FALSE)
usrep23_df <- usrep23_df[,-c(9:11)]
usrep23_df2 <- melt(usrep23_df, id="ED")

usrep23_df2 <- usrep23_df2 %>%
  separate(variable, c("candidate", "party"), "\\.{3,}")

usrep23_df2$county <- county
usrep23_df2$office <- "U.S. House"
usrep23_df2$district <- "23"
usrep23_df2 <- usrep23_df2[,c(5,1,6,7,3,2,4)]
colnames(usrep23_df2)[2] <- "precinct"
colnames(usrep23_df2)[7] <- "votes"

usrep23_df2$candidate <- gsub("\\.{1,}", " ", usrep23_df2$candidate)
usrep23_df2[usrep23_df2 == "Write in"] <- "Write-in"

write.csv(usrep23_df2, file="ont_usrep23.csv", row.names = F)

# U.S. House 27
usrep27_df <- read.csv(file, skip=348, nrows = 54, stringsAsFactors = FALSE)
usrep27_df <- usrep27_df[,-c(8:11)]
usrep27_df2 <- melt(usrep27_df, id="ED")

usrep27_df2 <- usrep27_df2 %>%
  separate(variable, c("candidate", "party"), "\\.{3,}")

usrep27_df2$county <- county
usrep27_df2$office <- "U.S. House"
usrep27_df2$district <- "27"
usrep27_df2 <- usrep27_df2[,c(5,1,6,7,3,2,4)]
colnames(usrep27_df2)[2] <- "precinct"
colnames(usrep27_df2)[7] <- "votes"

usrep27_df2$candidate <- gsub("\\.{1,}", " ", usrep27_df2$candidate)
usrep27_df2[usrep27_df2 == "Write in"] <- "Write-in"

write.csv(usrep27_df2, file="ont_usrep27.csv", row.names = F)

# State Senate 54
nysen54_df <- read.csv(file, skip=406, nrows = 66, stringsAsFactors = FALSE)
nysen54_df <- nysen54_df[,-c(8:11)]
nysen54_df2 <- melt(nysen54_df, id="ED")

nysen54_df2 <- nysen54_df2 %>%
  separate(variable, c("candidate", "party"), "\\.{3,}")

nysen54_df2$county <- county
nysen54_df2$office <- "State Senate"
nysen54_df2$district <- "54"
nysen54_df2 <- nysen54_df2[,c(5,1,6,7,3,2,4)]
colnames(nysen54_df2)[2] <- "precinct"
colnames(nysen54_df2)[7] <- "votes"

nysen54_df2$candidate <- gsub("\\.{1,}", " ", nysen54_df2$candidate)
nysen54_df2[nysen54_df2 == "Write in"] <- "Write-in"

write.csv(nysen54_df2, file="ont_nysen54.csv", row.names = F)

# State Senate 55
nysen55_df <- read.csv(file, skip=476, nrows = 30, stringsAsFactors = FALSE)
nysen55_df <- nysen55_df[,-c(7:11)]
nysen55_df2 <- melt(nysen55_df, id="ED")

nysen55_df2 <- nysen55_df2 %>%
  separate(variable, c("candidate", "party"), "\\.{3,}")

nysen55_df2$county <- county
nysen55_df2$office <- "State Senate"
nysen55_df2$district <- "55"
nysen55_df2 <- nysen55_df2[,c(5,1,6,7,3,2,4)]
colnames(nysen55_df2)[2] <- "precinct"
colnames(nysen55_df2)[7] <- "votes"

nysen55_df2$candidate <- gsub("\\.{1,}", " ", nysen55_df2$candidate)
nysen55_df2[nysen55_df2 == "Write in"] <- "Write-in"

write.csv(nysen55_df2, file="ont_nysen55.csv", row.names = F)

# State Assembly 131
nyassm131_df <- read.csv(file, skip=510, nrows=94, stringsAsFactors = FALSE)
nyassm131_df <- nyassm131_df[,-c(7:11)]
nyassm131_df2 <- melt(nyassm131_df, id="ED")

nyassm131_df2 <- nyassm131_df2 %>%
  separate(variable, c("candidate", "party"), "\\.{3,}")

nyassm131_df2$county <- county
nyassm131_df2$office <- "State Assembly"
nyassm131_df2$district <- "131"
nyassm131_df2 <- nyassm131_df2[,c(5,1,6,7,3,2,4)]
colnames(nyassm131_df2)[2] <- "precinct"
colnames(nyassm131_df2)[7] <- "votes"

nyassm131_df2$candidate <- gsub("\\.{1,}", " ", nyassm131_df2$candidate)
nyassm131_df2[nyassm131_df2 == "Write in"] <- "Write-in"

write.csv(nyassm131_df2, file="ont_nyassm131.csv", row.names = F)
