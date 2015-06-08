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

get_measures_from_day <- function (date, measure, limit) {
  query = paste("SELECT * FROM aliss15a_daily_words dw  JOIN words  ON dw.w_id=words.w_id WHERE date=Date( '", date,  "' ) ORDER BY dw.",measure," DESC LIMIT ", limit, sep='')
  print(query)
  response = dbSendQuery(mydb, query)
  fetch(response, n=-1)
}

get_measures_from_day <- function (date, measure, limit) {
  query = paste("SELECT * ",
                "FROM aliss15a_daily_words dw  ",
                "JOIN words  ",
                "ON dw.w_id=words.w_id ",
                "JOIN daily_words ",
                "ON dw.w_id=daily_words.w_id AND dw.date=daily_words.date",
                "WHERE dw.date=Date( '", date,  "' ) ",
                "ORDER BY ",measure,
                " DESC LIMIT ", limit,
                sep='')
  print(query)
  response = dbSendQuery(mydb, query)
  fetch(response, n=-1)
}

# Clear Resultset
# dbClearResult(dbListResults(mydb)[[1]])
day <- "2015-05-01"
tf_idf <- get_measures_from_day(day, "dw.tf_idf", "10")
poisson <- get_measures_from_day(day, "dw.poisson", "100")
poisson_old <- get_measures_from_day(day, "daily_words.poisson", "100")
freqratio <- get_measures_from_day(day, "dw.freqratio", "100")
freqratio_old <- get_measures_from_day(day, "daily_words.freqratio", "100")
z_score <- get_measures_from_day(day, "dw.z_score", "100")

#versuchSQL <- "SELECT * FROM aliss15a_daily_words dw  JOIN words ON dw.w_id=words.w_id  WHERE dw.date=Date('15-04-01') ORDER BY dw.tf_idf DESC LIMIT 100"
#versuch2SQL <- "SELECT * FROM (SELECT * FROM aliss15a_daily_words WHERE date=Date( '15-03-01')) dw  JOIN words ON dw.w_id=words.w_id ORDER BY dw.tf_idf DESC LIMIT 100"
#response = dbSendQuery(mydb, versuchSQL)
#fetch(response, n=-1)


#freqratio <- get_measures_from_day("2015-05-01", "freqratio", "10")
all_meassures <- cbind(tf_idf$word, poisson$word, z_score$word, freqratio$word)
average_overlap_data <- multiple_average_overlap(all_meassures)
average_overlap_data <- as.data.frame(average_overlap_data)
colnames(average_overlap_data) <- c("List","List_to_compare", "average_overlap")
average_overlap_data$List <- as.factor(average_overlap_data$List)
levels(average_overlap_data$List) <- c("tf_idf", "poisson", "z-score", "freqratio")
average_overlap_data$List_to_compare <- as.factor(average_overlap_data$List_to_compare)
levels(average_overlap_data$List_to_compare) <- c( "poisson", "z-score", "freqratio")

average_overlap_data

# Plot as graph
library(igraph)
xlist <- read.graph("http://www.ats.ucla.edu/stat/data/elist1.txt", format = "edgelist")
str(xlist)
 plot.igraph(xlist)
 plot.igraph(graph(t(average_overlap[, 1:2]), directed=FALSE ))
??igraph
