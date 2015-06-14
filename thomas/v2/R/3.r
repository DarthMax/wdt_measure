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




