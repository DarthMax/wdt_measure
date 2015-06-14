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




# CONNECT TO DB
# =============
library(RMySQL)
## HIER DB DATEN EINTRAGEN !!!
us="aliss15a"
pw="W-aBnP4$f"
db="deu_news_2015"
host="127.0.0.1"
port=3307

#load db conf from file if file exists else use data from above
# copy .wdt_measure_dbconf.csvprop.dist in working directory and add your data. Stor file without .dist
dbconf <- NULL
#try(dbconf <- read.table('.wdt_measure_dbconf.csvprop', header=FALSE, sep = ',', strip.white=TRUE))
if (!is.null(dbconf)) {
  mydb = dbConnect(
    MySQL(),
    user = as.character(dbconf[dbconf$V1=='user',2]),
    password = as.character(dbconf[dbconf$V1=='password',2]),
    dbname = as.character(dbconf[dbconf$V1=='dbname',2]),
    host = as.character(dbconf[dbconf$V1=='host',2]),
    port = as.integer(as.character(dbconf[dbconf$V1=='port',2]))
  )
} else {
  mydb = dbConnect(MySQL(), user=us, password=pw, dbname=db, host=host,port=port)
}


