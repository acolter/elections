# Elections data

The [OpenElections Project](http://www.openelections.net/) is compiling a set of standardized, precinct-level results for national and state level elections. When it's finished the dataset will be useful for all sorts of folks who want to interpret the data, including journalists, academics, campaigns, and anyone else who's interested.

The quality of the data varies from state to state and even precinct to precinct. If you're lucky the data's in an Excel file; sometimes you might have to use [Tabula](http://tabula.technology/) to create a comma delimited file from a .pdf; and some times it's a hand-written document that somebody scanned and that has to be converted by hand. 

I wrote a script that automates most of the work to reshape .xls files from two New York counties in the 2016 general election -- Montgomery and Ontario -- to something more tidy in .csv format. 
