#install.packages('quantmod', repos="http://cran.rstudio.com/")
require("quantmod")

# Get Dow Jones 20 Bond Price Index data from Google
# Scratch that. Use LQD as a liquid equivalent
bondIndex <- na.omit(getSymbols("LQD",src="google",auto.assign = FALSE))
bondIndex <- bondIndex[,c(0,4)]
bondIndex$score <- 0

# get S&P 500 data from FRED
sp500 <- na.omit(getSymbols("SP500",src = "FRED",from = "1949-12-31",auto.assign = FALSE))

# add 200 day moving average
sp500$ma <- runMean(sp500[,1], n=200)

# Score a +1 when the Index rises from a bottom price low by 0.6%.  Score a -1 when the index falls from a peak price by 0.6%.
runLength = 365 # The rules don't state what a "bottom" price is. We're using the lowest price in the past year.

bondIndex$low <- runMin(bondIndex,runLength)
bondIndex$high <- runMax(bondIndex,runLength)

bondIndex$score <- ifelse(bondIndex[,c(1)] > (bondIndex$low * 1.006), bondIndex$score + 1, bondIndex$score)
bondIndex$score <- ifelse(bondIndex[,c(1)] < (bondIndex$high * .994), bondIndex$score - 1, bondIndex$score)

print (bondIndex$score)