# Daily Kos Elections Data Calculation Project ReadMe.md
This project calculates the results of the 2018 elections for senator and governor, broken down by congressional district and legislative district. 

## Overview

This repo contains several files: 
* Official precinct-level results by county - statewide and district offices as amended by Miami County for the 2018 election in Ohio pulled from https://www.sos.state.oh.us/globalassets/elections/2018/gen/2018-11-06_statewideprecinct_miami.xlsx
* ohio_tidy.R is the script that produced the tidy data set
* undervote_factor.R is the script that calculates how to allocate votes in split precincts
* CodeBook.md describes the variables, values, and units in the tidy data set.
* gov_tidy.csv is the tidy subset of Ohio 2018 governor election data. Its dimensions are 26,712 rows by 5 columns. 
* ga_tidy.csv is the tidy subset of Ohio 2018 state legislative election data. Its dimensions are 17,969 by 5 columns.

Both csv files adhere to the following tidy data principles:

	* Each variable in one column
	* Each observation in a different row
	* One table for each observation unit  

## Raw Data

* gov_tidy.csv includes the data set from the Statewide Offices worksheet of the amended results workbook
* ga_tidy.csv includes the data set from the from the Gen Assembly worksheet of the amended results workbook

## Script

# ohio_tidy.R 

Takes the raw data from the precinct-level results for statewide offices and general assembly, imports them into R, and transforms them into a tidy data subset. The script performs the following operations:

1. Labels the statewide data set with descriptive variable names.
2. Extracts county names, precinct names and vote totals by candidate and office.
3. Creates a sum of all votes for governor candidates in each precinct.
	* Selects columns for the (D) and (R) candidates, remove all other candidate columns.
	* Gathers the candidate last name and precinct_total columns and create a gov_votes column with total votes for governor
4. Labels the general assembly data set with descriptive variable names. 
	* Uses locf to replace NA values with house districts
	* Separates column names into candidate names and house districts
5. Creates a sum of all votes for state house candidates in each precinct. 
	* Selects columns for the (D) and (R) candidates, remove all other candidate columns.
	* Gathers the candidate last name and precinct_total columns and create a house_votes column with total votes for state representative
6. Joins the governor and house district data set by county and precinct.

# undervote_factor.R
tbd
