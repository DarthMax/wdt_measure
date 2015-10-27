# This file contains the r code to create the example graphs in the seminararbeit

poisson_lambda <- function(k) {
  lambda = 80
  #erwartete Ereignishaeufigkeit in Zeitraum (zum Beispiel ein Jahr)
  (lambda^k/factorial(k))*exp(1)^(-lambda)
}
#((poisson_lambda(170)))/log(exp(1))

poisson_illustration <- data.frame(counted_token=1:165, probability=mapply(poisson_lambda,1:165))
library(ggplot2)
ggplot(poisson_illustration, aes(x=counted_token, y=probability )) +
  geom_point (size=1) +
  geom_line(aes(x=80), colour='red') +
  xlab("Frequence of token 'Flugzeug'") +
  ggtitle("Poisson illustration for example word 'Flugzeug' on 25.03.2015" ) +
  theme(plot.title = element_text(lineheight=.8, face="bold"))


poisson_lambda_log <- function(k) {
  #erwartete Ereignishaeufigkeit in Zeitraum (zum Beispiel ein Jahr)
  lambda <- 80
  -log((lambda^k/factorial(k))*exp(1)^(-lambda))
}
poisson_illustration2 <- data.frame(counted_token=1:165, log_probability=mapply(poisson_lambda_log,1:165))
library(ggplot2)
ggplot(poisson_illustration2, aes(x=counted_token, y=log_probability )) +
  geom_point (size=1) +
  geom_line(aes(x=80), colour='red') +
  xlab("Frequence of token 'Flugzeug'") +
  ylab("= log(poisson measure)") +
  ggtitle("-log poisson illustration for example word 'Flugzeug' on 25.03.2015" ) +
  theme(plot.title = element_text(lineheight=.8, face="bold"))


poisson_lambda_measure <- function(k) {
  #erwartete Ereignishaeufigkeit in Zeitraum (zum Beispiel ein Jahr)
  lambda <- 80
  (k*(log(k)-log(lambda)-1))/log(2220601)
  #-log((lambda^k/factorial(k))*exp(1)^(-lambda))
}
poisson_illustration2 <- data.frame(counted_token=1:500, log_probability=mapply(poisson_lambda_measure,1:500))
library(ggplot2)
ggplot(poisson_illustration2, aes(x=counted_token, y=log_probability )) +
  geom_point (size=0.5) +
  geom_line(aes(x=80), colour='red') +
  geom_line(aes(y=0), colour='red') +
  xlab("Frequence of token 'Flugzeug'") +
  ylab("Poisson measure") +
  ggtitle("Poisson measure illustration for example word 'Flugzeug' on 25.03.2015" ) +
  theme(plot.title = element_text(lineheight=.8, face="bold"))

# Im Jahr 568 000 000 Wörter
# Flugzeug 2014 20366
# 25.3.2015
# daily words  2 220 601
# freq "Flugzeug" 535 w_id=1491
relative_example <- function(freq) {
  (freq/2220601)/(20366/568000000)
}
relfreq_illustration <- data.frame(counted_token=1:165, relative_freq=mapply(relative_example,1:165))
ggplot(relfreq_illustration, aes(x=counted_token, y=relative_freq )) +
  geom_point (size=1) +
  geom_line(aes(y=1), colour='red') +
  geom_line(aes(x=80), colour='red') +
  xlab("Frequence of token 'Flugzeug'") +
  ylab("Relative frequency") +
  ggtitle("Relative frequency illustration for example word 'Flugzeug' on 25.03.2015" ) +
  theme(plot.title = element_text(lineheight=.8, face="bold"))




#TFIDF Illustration
max freq am Tag 58873
Gemessene Tage im Jahr
Flugzeug Dokumente
w_id 2014 7543
relative document frequency 0.997238
example_tf_idf100 <- function(k) {(k/60000)*log(1/1)}
example_tf_idf10 <- function(k) {(k/60000)*log(1/0.1)}
example_tf_idf1 <- function(k) {(k/60000)*log(1/0.01)}
example_tf_idf01 <- function(k) {(k/60000)*log(1/0.001)}
example_tf_idfmax <- function(k) {(k/60000)*log(365/1)}
example_tf_idf(500)
tfidf_illustration <- data.frame(counted_token=1:165,
                                 measure100=mapply(example_tf_idf100,1:165),
                                 measure10=mapply(example_tf_idf10,1:165),
                                 measure1=mapply(example_tf_idf1,1:165),
                                 measure01=mapply(example_tf_idf01,1:165),
                                 measuremax=mapply(example_tf_idfmax,1:165)
                                 )
ggplot(tfidf_illustration, aes(x=counted_token, y=measure100)) +
  geom_line (colour='red') +
  geom_line(aes(y=measure10), colour='yellow') +
  geom_line(aes(y=measure1), colour='orange') +
  geom_line(aes(y=measure01), colour='green') +
  geom_line(aes(y=measuremax), colour='grey') +
  xlab("Frequence of fictive example token") +
  ylab("tf-idf measure") +
  ggtitle("TF-IDF illustration for fictive example word (tf:100%, 10%, 1%, 2,7%, 0.1%)") +
  theme(plot.title = element_text(lineheight=.8, face="bold"))


log(365/133)
1/365
1/(365/133)
poisson_mass <- function(k, lambda) {
  (k*(log(k)-log(lambda)-1))#/log(100000)
}
poisson_mass(170,10)
exp(1)
factorial(10)
log(exp(1))
log(exp(-100))
??data.frame
w_id <- c(1,2,3,4)
tv <- c(6,5,5,5)
tvtcwr <- c(1,1,1,1)
tvtcwr_new <- c(2,3,2,3)
testdata <- data.frame(w_id=w_id, test_value=tv, test_value_to_change_with_r=tvtcwr)
testdata <- data.frame(w_id=w_id, test_value_to_change_with_r=tvtcwr_new)
