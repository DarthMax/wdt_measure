
library(RMySQL)

## HIER DB DATEN EINTRAGEN !!!

us=""
pw=""
db=""
host=""

mydb = dbConnect(MySQL(), user=us, password=pw, dbname=db, host=host)

query = "select * from words w inner join daily_words dw on dw.w_id=w.w_id and w.word='Haus'"

response = dbSendQuery(mydb, query)

data = fetch(response, n=-1)



