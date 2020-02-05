# Daily Kos Elections Data Calculation Project ReadMe.md
This project calculates the results of the 2018 elections for senator and governor, broken down by congressional district and legislative district. 

## Overview

This repo contains several files: 
* Official results for the 2018 election in Ohio pulled from
https://www.sos.state.oh.us/globalassets/elections/2018/gen/2018-11-06_statewideprecinct_miami.xlsx 
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

join_tidy.csv includes the combined test and training data sets from the following sheets:

* Statewide Offices
* Gen Assembly

## Script

tbd


