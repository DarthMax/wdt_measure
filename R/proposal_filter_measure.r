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

#RESHAPE I
#=========
#Make big table

#install.packages("reshape2")
library(reshape2)
# Reshape Data in one big table : Zeile: date ~ Spalte: word
# varie value.var to use other data then freq (for exaple tf/idf)
words_vs_date <- dcast(marchData[ ,], formula = date ~ w_id, mean, value.var="freq", fill=0)
# add new column names, becaus integers as columnnames produce failures 
wordNames <- colnames(words_vs_date)
add_w_id <- function(id) {paste("w_id_",id,sep="")}
wordNames <- mapply(add_w_id, wordNames)
colnames(words_vs_date) <- wordNames


# CALCULATION 
# ===========
# Calculate filter with 8 days
# add more calculations if wanted
days_back = 8
time_series_data <- filter(words_vs_date[ ,2:length(colnames(words_vs_date)) ], rep(1/days_back,days_back), sides=1 )
#Berechnung  im Zeitraum dauert 2 Minuten
ts<- as.data.frame(time_series_data)
dim(ts)
colnames(ts) <- wordNames[-1] # woerter wieder als spaltennamen
ts$date_of_wordentry <- as.Date(words_vs_date[,1]) # Date einfuegen.


#PLOT EXAMPLE WORD "Flugzeug"
#============================
library(ggplot2)
words_vs_date$date_of_wordentry <- as.Date(words_vs_date[,1])
plot_data <-words_vs_date[,c("w_id_1491","date_of_wordentry" ) ]
plot_data$window  <-ts[,c("w_id_1491") ]
??ggplot
ggplot(plot_data , aes(x=date_of_wordentry, y=w_id_1491 )) +
  geom_line() +
  geom_point () +
  geom_line(data = plot_data, aes(y = window),
             colour = 'red', size = 1) +
  scale_x_date() +
  ggtitle("Wordfrequency on date" )
  theme(plot.title = element_text(lineheight=.8, face="bold"))


#RESHAPE II
#==========
# prepare data for mysql (melt down big table and rename w_ids)
# Goal of three columns: date, w_id, window8
# 15:41
data_for_mysql <- ts[]
data_for_mysql$date <- words_vs_date[,c("date_of_wordentry" ) ] # add right dates
# melting porocess
data_for_mysql <- melt(data_for_mysql, "date",1:(length(colnames(data_for_mysql))-1), variable.name="w_id", value.name="window8")
# <2min
# get w_ids as numeric ("w_id_5" => 5)
string_without_w_id <- function(w_id_name) {as.numeric(substr(w_id_name,6, nchar(w_id_name)))} 
data_for_mysql$w_id <- string_without_w_id(as.character(data_for_mysql$w_id))


# WRITE IN MySQL
# ==============
# overwrite Data in mysql in table "aliss15a_windows_of_r"
dbWriteTable(mydb, "aliss15a_windows_of_r", data_for_mysql, overwrite = TRUE, append=FALSE, row.names=FALSE, field.types=list(date="date", w_id="int (10)", window8="float"))
#das dauert jetzt lange wegen meiner internetverbindung

