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


