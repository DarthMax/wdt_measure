
library(RMySQL)

## HIER DB DATEN EINTRAGEN !!!

us=""
pw=""
db=""
host=""

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
  mydb = dbConnect(MySQL(), user=us, password=pw, dbname=db, host=host)
}

query="drop table if exists alliss15R"

dbSendQuery(mydb,query)

query="select min(date),max(date) from daily_words"

response=dbSendQuery(mydb,query)

minmax = fetch(response,n=-1)


query="select w_id from words";

response_words= dbSendQuery(mydb,query);

words = fetch(response_words,n=-1);


f <- function(x){

    dates=(as.data.frame(seq(as.Date(minmax[1,1],"%Y-%m-%d"), as.Date(minmax[1,2],"%Y-%m-%d"),by='day')))

    colnames(dates) <- c("date")
   
    dates[1]<-lapply(dates[1], as.character)

    query=paste("select * from daily_words dw where  dw.w_id=",x)
    
    response=dbSendQuery(mydb,query);

    data=fetch(response,n=-1);
    
    data2 = merge(dates,data,by.y="date",all.x=TRUE)
    
    data2[is.na(data2)]<-0

    datalin1 = filter(data2[,4],rep(1/11,11),sides=1)
    data2[, "lin_filt_11" ] = datalin1;

    datalin2 = filter(data2[,4],rep(1/3,3),sides=1)
    data2[, "lin_filt_3" ] = datalin2;

    datalin3 = c(NA,NA,fitted(HoltWinters(data2[,4],gamma=FALSE))[,1])
    data2[, "HoltWinters" ] =datalin3;
    dbWriteTable(mydb,"alliss15R",data2,append=T)
}

# Berechnung startet hier
apply(words,c(1,2),f)

dbDisconnect(mydb)

