# Elections data

The [OpenElections Project](http://www.openelections.net/) is compiling a set of standardized, precinct-level results for national and state level elections. When it's finished the dataset will be useful for those who want to interpret the data, including journalists, academics, campaigns, and anyone else who's interested.

The quality of the data varies from state to state and county to county. If you're lucky the data's in an Excel file; sometimes you might have to use [Tabula](http://tabula.technology/) to create a comma delimited file from a .pdf. The really challenging ones are hand-written or scanned documents that aren't machine-readable. Those have to get converted by an optical character recognition program first. 

I wrote a script that automates most of the work to reshape .xls files from two New York counties in the 2016 general election -- Montgomery and Ontario -- to something more tidy in .csv format. More recently I've used it to process Oregon precinct files going back to 2000. 

Here's my process:
- Take a look at the original PDF file to see if it's machine readable or not. 
- If it needs some OCR love, run it through your favorite OCR converter. Mine's ABBYY FineReader. Not free, but worth every penny if you have a lot of files to convert. 
- Import the .xls output to a spreadsheet program (I use Google Sheets) and confirm that the file converted correctly and all the vote tallys add up. This is the part that takes the longest time, particularly if the original document is smudged, skewed or hand-written. 
- Export each office to a .csv file, then run it through the R script to reshape the file the way the Open Elections folks want it. 
- Import each office output back into the spreadsheet. Then export the whole thing as a .csv file.
