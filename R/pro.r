
library(RMySQL)

## HIER DB DATEN EINTRAGEN !!!

us=""
pw=""
db=""
host=""

#load db conf from file if file exists else use data from above
# copy .wdt_measure_dbconf.csvprop.dist in working directory and add your data. Stor file without .dist
dbconf <- NULL
try(dbconf <- read.table('.wdt_measure_dbconf.csvprop', header=FALSE, sep = ',', strip.white=TRUE))
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
  mydb = dbConnect(MySQL(), user=us, password=pw, dbname=db, host=host)
}


query = "select * from words w inner join daily_words dw on dw.w_id=w.w_id and w.word='Haus'"

response = dbSendQuery(mydb, query)

data = fetch(response, n=-1)


