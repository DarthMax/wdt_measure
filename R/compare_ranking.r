# ranked bias overlap
# http://williamwebber.com/research/papers/wmz10_tois.pdf
# idea: compare the intersection between lists.
# But: Do this for sublists from rank one to to n vor all n in N (last rank)

average_overlap <- function(lists ) {
  # calc (number of intersected elements / number of elements in each list) in a 2,x sized vector form sublists 1:n

  intersect_n_elements <- function (n, lists){
    length(intersect(lists[1,1:n],lists[2,1:n]))/n
  }
  sum(mapply(intersect_n_elements, 1:length(lists[,1]), list(rbind(lists[,1],lists[,2])))) / length(lists[,1])
}
#test#
test_average_overlap <- function () {
  print("test average_overlap")
  print("calc vs. manual calc:")
  lists <- cbind( c("hallo", "bist", "kannst", "Du"),
                  c("hallo", "wer", "bist", "Du"))
  average_overlap(lists) == (1/1+1/2+2/3+3/4)/4
}
test_average_overlap()


## Average Overlap on n different lists to compare
#install.packages("iterpc")
library(iterpc) # to get all combinations from list
multiple_average_overlap <- function(ranked_lists) {
  # calculate all distances from given list of indices to compare
  calc_distances <- function(indices) {
    average_overlap(cbind(ranked_lists[,indices[1]],ranked_lists[,indices[2]]))
  }
  nr_of_lists <- dim(ranked_lists)[2]
  combination_iterator = iterpc(nr_of_lists, 2) # get all combinations as iterator
  all_comb <- getall(combination_iterator)
  cbind(all_comb, apply(all_comb, 1, calc_distances))
}



test_multiple_average_overlap <- function () {
  all_lists <- cbind( c("hallo", "bist", "kannst", "Du" ),
                 c("hallo", "wer", "bist", "Du"),
                 c("bist", "hallo", "kannst", "Du")
                 )
  multiple_average_overlap(all_lists)
}

test_multiple_average_overlap()


## Test on real data
dbGetQuery(mydb, "SET NAMES 'utf8'") #utf-8

get_measures_from_day <- function (date, measure, limit) {
  query = paste("SELECT * ",
                "FROM aliss15a_daily_words dw  ",
                "JOIN words  ",
                "ON dw.w_id=words.w_id ",
                "JOIN daily_words ",
                "ON dw.w_id=daily_words.w_id AND dw.date=daily_words.date ",
                "WHERE dw.date=Date( '", date,  "' ) ",
                "ORDER BY ",measure,
                " DESC LIMIT ", limit,
                sep='')
  print(query)
  response = dbSendQuery(mydb, query)
  fetch(response, n=-1)
}

get_z_value<- function() {
  query <- "SELECT
now.z_score,
now_daily_words.freq,
now.relative_freq,
ref_aliss.mean,
ref_aliss.standard_derivation,
ref_aliss.relative_document_frequency,
ref.word,
now_words.word
FROM aliss15a_daily_words as now
JOIN daily_words as now_daily_words on now.w_id = now_daily_words.w_id and now.date = now_daily_words.date
JOIN words as now_words on now_words.w_id = now.w_id
JOIN deu_news_2014.words as ref on now_words.word = ref.word
JOIN deu_news_2014.aliss15a_words as ref_aliss on ref.w_id = ref_aliss.w_id
WHERE now.date=Date('2015-03-25') AND ((now.relative_freq > (@threshold*10) AND ref_aliss.relative_document_frequency < 0.1) OR ref_aliss.relative_document_frequency >= 0.1)
ORDER BY now.z_score desc
LIMIT 100;"
  response = dbSendQuery(mydb, query)
  fetch(response, n=-1)
}

get_relwindow <- function() {
  query <- "select words.word, daily.date, daily.freq,win.window8, daily.freq/win.window8 relWindow From aliss15a_windows_of_r win JOIN words ON win.w_id=words.w_id JOIN daily_words daily ON daily.w_id=win.w_id AND daily.date=win.date WHERE win.date=Date('2015-03-25') AND daily.date=('2015-03-25') AND daily.freq>100 ORDER BY relWindow DESC limit 100;"
  response = dbSendQuery(mydb, query)
  fetch(response, n=-1)
 }
1/365
# Clear Resultset
# dbClearResult(dbListResults(mydb)[[1]])
day <- "2015-03-25"
tf_idf <- get_measures_from_day(day, "dw.tf_idf", "100")
poisson <- get_measures_from_day(day, "dw.poisson", "100")
poisson_old <- get_measures_from_day(day, "daily_words.poisson", "100")
freqratio <- get_measures_from_day(day, "dw.freqratio", "100")
freqratio_old <- get_measures_from_day(day, "daily_words.freqratio", "100")
lin_filt_freq <- get_measures_from_day(day, "lin_filt_freq", "100")
z_score <- get_z_value()
relWindow <- get_relwindow()

allInOne <- as.data.frame(poisson[,c("word")])
colnames(allInOne) <- c("poisson")
allInOne$tf_idf <- tf_idf[,c("word")]
allInOne$freqratio <- freqratio[,c("word")]
allInOne$z_score <- z_score[,c("word")]

z_score[1:20,c("word","freq")]
relWindow[1:20,c("word","freq")]


library(xtable)
xtable(allInOne[1:10,1:2], digits=2)
xtable(allInOne[1:10,3:4], digits=2)
xtable(allInOne[31:40,1:2], digits=2)
xtable(allInOne[31:40,3:4], digits=2)

??xtable



#versuchSQL <- "SELECT * FROM aliss15a_daily_words dw  JOIN words ON dw.w_id=words.w_id  WHERE dw.date=Date('15-04-01') ORDER BY dw.tf_idf DESC LIMIT 100"
#versuch2SQL <- "SELECT * FROM (SELECT * FROM aliss15a_daily_words WHERE date=Date( '15-03-01')) dw  JOIN words ON dw.w_id=words.w_id ORDER BY dw.tf_idf DESC LIMIT 100"
#response = dbSendQuery(mydb, versuchSQL)
#fetch(response, n=-1)


#freqratio <- get_measures_from_day("2015-05-01", "freqratio", "10")
all_meassures <- cbind(tf_idf$word, poisson$word, z_score$word, freqratio$word)
#all_meassures <- cbind(poisson$word,freqratio$word, freqratio_old$word, poisson_old$word)
average_overlap_data <- multiple_average_overlap(all_meassures)
#Format data in data frame
average_overlap_data <- as.data.frame(average_overlap_data)
colnames(average_overlap_data) <- c("List","List_to_compare", "average_overlap")
average_overlap_data$List <- as.factor(average_overlap_data$List)
levels(average_overlap_data$List) <- c("tf-idf", "z-score","poisson", "freqratio" )
#levels(average_overlap_data$List) <- c("tf_idf","poisson", "z-score", "freqratio")
average_overlap_data$List_to_compare <- as.factor(average_overlap_data$List_to_compare)
#levels(average_overlap_data$List_to_compare) <- c("freqratio","freqratio_old", "poisson_old")
levels(average_overlap_data$List_to_compare) <- c( "z-score","poisson", "freqratio")
#result
average_overlap_data


# data frame as tex table
library(xtable)
xtable(average_overlap_data, label = 'AvarageOverlapComparison', caption = 'Avarage Overlap Comparison')
?xtable


#save as tsv
#header for tsv (to plot graph with d3
colnames(average_overlap_data) <- c("source", "target", "value")
write.table(average_overlap_data, file='Projects/Webprojects/wortschatzMitNeuemGraph/cooc-example/comparison.tsv', quote=FALSE, sep='\t',row.names = F)



