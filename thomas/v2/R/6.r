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

# WRITE IN MySQL
# ==============
# overwrite Data in mysql in table "aliss15a_windows_of_r"
dbWriteTable(mydb, "aliss15a_windows_of_r", data_for_mysql, overwrite = TRUE, append=FALSE, row.names=FALSE, field.types=list(date="date", w_id="int (10)", window8="float"))
#das dauert jetzt lange wegen meiner internetverbindung

