
poisson_lambda <- function(k, lambda) {
  #erwartete Ereignishaeufigkeit in Zeitraum (zum Beispiel ein Jahr)
  lambda <- 10
  (lambda^k/factorial(k))*exp(1)^(-lambda)
}
((poisson_lambda(170)))/log(exp(1))

poisson_illustration <- data.frame(counted_token=1:50, probability=mapply(poisson_lambda,1:50))
library(ggplot2)
ggplot(poisson_illustration, aes(x=counted_token, y=probability )) +
  geom_point () +
  ggtitle("Poisson Illustration for example word" ) +
  theme(plot.title = element_text(lineheight=.8, face="bold"))

poisson_lambda_log <- function(k) {
  #erwartete Ereignishaeufigkeit in Zeitraum (zum Beispiel ein Jahr)
  lambda <- 10
  -log((lambda^k/factorial(k))*exp(1)^(-lambda))
}
poisson_illustration2 <- data.frame(counted_token=1:50, log_probability=mapply(poisson_lambda_log,1:50))
library(ggplot2)
ggplot(poisson_illustration2, aes(x=counted_token, y=log_probability )) +
  geom_point () +
  ggtitle("Poisson Illustration for example word" ) +
  theme(plot.title = element_text(lineheight=.8, face="bold"))

# Im Jahr 568 000 000 Wörter
# Flugzeug 2014 20366
# 25.3.2015
# daily words  2 220 601
# freq "Flugzeug" 535 w_id=1491
relative_example <- function(freq) {
  (freq/2220601)/(20366/568000000)
}
relfreq_illustration <- data.frame(counted_token=1:100, relative_freq=mapply(relative_example,1:100))
ggplot(relfreq_illustration, aes(x=counted_token, y=relative_freq )) +
  geom_point () +
  ggtitle("Relfrequency Illustration for example word 'Flugzeug' on 25.03.2015" ) +
  theme(plot.title = element_text(lineheight=.8, face="bold"))





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
