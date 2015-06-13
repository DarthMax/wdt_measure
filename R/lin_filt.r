
library(RMySQL)

## HIER DB DATEN EINTRAGEN !!!

us="aliss15a"
pw="W-aBnP4$f"
db="deu_news_2015"
host="127.0.0.1"
port=3307


mydb = dbConnect(MySQL(), user=us, password=pw, dbname=db, host=host,port=port)

## Variablen ###

from_date="2015-03-01";
to_date="2015-03-30";

# Erstelle ein Leeres Dateframe für den Zeitraum

dates=(as.data.frame(seq(as.Date(from_date,"%Y-%m-%d"),as.Date(to_date,"%Y-%m-%d"),by='day')))
colnames(dates) <- c("date")
dates[1]<-lapply(dates[1], as.character)

print("Timeframe erstellt")

## Variablen Ende ##

## Querys ##

q_word_ids = "select w_id from words"
q_show_tables = "Show tables"
q_get_word_data = "Select * from daily_words dw where dw.w_id="
q_drop_help_table = "drop table if exists alis15a_R"
## Querys Ende

## Funktionen ##

# lin filter

lin_filt <- function(data,pos,a){
    datalin = filter(data[,pos],rep(1/a,a),sides=1)
    return (datalin)
}

do_query_without_data <- function(x){
    dbSendQuery(mydb,x)
}

# Führt eine SQL Query aus
do_query <- function(x){
    response=dbSendQuery(mydb,x);
    data=fetch(response,n=-1);
    dbClearResult(dbListResults(mydb)[[1]]);
    return (data);
}



# Berechnet die Maße
compute_data <- function(x) {
    word_data = do_query(paste(q_get_word_data,x))
    # Merge das Datedataset mit den gefunden Wörter um ein vollständige Zeitstrahl
    # ohne Lücken zu haben
    word_data = merge(dates,word_data,by.y="date",all.x=TRUE)
    word_data[is.na(word_data)]<-0

    word_data[,"lin_filt_11"] = lin_filt(word_data,4,11);
    word_data[,"lin_filt_3"] = lin_filt(word_data,4,3);
    
    dbWriteTable(mydb,"alis15a_r",word_data,append=T)
}

## Funktionen Ende ##

do_query_without_data(q_drop_help_table)

words = do_query(q_word_ids);
print("Wörter wurden geholt");
apply(words,c(1,2),compute_data)


dbDisconnect(mydb)

