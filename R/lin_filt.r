plot(data[,8],type="l",xlab=data[1,2],ylab="Frequenz")

# Lineare Filter

data.lin1 <- filter(data[,8],rep(1/11,11),sides=1)
data.lin2 <- filter(data[,8],rep(1/3,3),sides=1)

lines(data.lin1, col="blue")
lines(data.lin2, col="red")

# Wird immer kürzer lässt sich irgendwie schlecht einstellen :/

# Exponentielle Filter

data.lin3 <- HoltWinters(data[,8],gamma=FALSE)

lines(fitted(data.lin3)[,1], col="darkgreen")
