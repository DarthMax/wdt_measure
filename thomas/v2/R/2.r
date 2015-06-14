# PROPOSAL TO CALCULATE WINDOW MEAN
# =================================
# =================================

# Idea: Get Data From all words in timespan, calculate, write back

# Steps
#   Connect to DB
#   Get all data from DB
#   Reshape 1: make big table
#   Calculation
#   Plot Example Word "Flugzeug"
#   Reshape II: make tall table (date, w_id, window_value)
#   Write back into DB




# GET DATA FROM DB
# ================
#get all data in timespan
sql_all_words_in_daterange = "
SELECT w_id, date, freq
FROM daily_words
WHERE date>'2015-03-5 00:00:00' AND date<'2015-03-31 00:00:00'"
rs = dbSendQuery(mydb, sql_all_words_in_daterange)
marchData = fetch(rs, n=-1) #fetch n number of results to get (-1 all)
marchData$date <- as.Date(marchData$date[]) # format date in class Date
#check Datespan if necessary
min(marchData$date)
max(marchData$date)

