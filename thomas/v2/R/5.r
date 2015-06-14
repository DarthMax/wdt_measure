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


#RESHAPE II
#==========
# prepare data for mysql (melt down big table and rename w_ids)
# Goal of three columns: date, w_id, window8
# 15:41
data_for_mysql <- ts[]
data_for_mysql$date <- ts[,c("date_of_wordentry")] # add right dates
# melting porocess
data_for_mysql <- melt(data_for_mysql, "date",1:(length(colnames(data_for_mysql))-1), variable.name="w_id", value.name="window8")
# <2min
# get w_ids as numeric ("w_id_5" => 5)
string_without_w_id <- function(w_id_name) {as.numeric(substr(w_id_name,6, nchar(w_id_name)))} 
data_for_mysql$w_id <- string_without_w_id(as.character(data_for_mysql$w_id))

