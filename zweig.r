#install.packages('quantmod', repos="http://cran.rstudio.com/")
require("quantmod")

fiveYearsAgo = Sys.Date() - (365 * 5)

# Get Dow Jones 20 Bond Price Index data from Google
# Scratch that. Use LQD as a liquid equivalent
bondIndex <- getSymbols("LQD",src="google",from = fiveYearsAgo, auto.assign = FALSE)[,c(0,4)]

bondIndex$score <- 0

# Rule 1:
# Score a +1 when the Index rises from a bottom price low by 0.6%.  Score a -1 when the index falls from a peak price by 0.6%.
runLength = 365 # The rules don't state what a "bottom" price is. We're using the lowest price in the past year.

bondIndex$low <- runMin(bondIndex,runLength)
bondIndex$high <- runMax(bondIndex,runLength)

bondIndex$score <- ifelse(bondIndex[,1] > (bondIndex$low * 1.006), bondIndex$score + 1, bondIndex$score)
bondIndex$score <- ifelse(bondIndex[,1] < (bondIndex$high * .994), bondIndex$score - 1, bondIndex$score)

# Rule 2:
# Score a +1 when the Index rises from a bottom price low by 1.8%.  Score a -1 when the index falls from a peak price by 1.8%.

bondIndex$score <- ifelse(bondIndex[,1] > (bondIndex$low * 1.018), bondIndex$score + 1, bondIndex$score)
bondIndex$score <- ifelse(bondIndex[,1] < (bondIndex$high * .982), bondIndex$score - 1, bondIndex$score)

# Rule 3:
# Score a +1 when the Index crosses above it's 50 day moving average by 1%.  Score a -1 when the index crosses below it's 50 day moving average by 1%.

bondIndex$fiftyDayMA <- na.spline(SMA(bondIndex[,1],50))

bondIndex$score <- ifelse(bondIndex[,1] > (bondIndex$fiftyDayMA * 1.01), bondIndex$score + 1, bondIndex$score)
bondIndex$score <- ifelse(bondIndex[,1] < (bondIndex$fiftyDayMA * .99), bondIndex$score - 1, bondIndex$score)


# Rule 4:
# Score a +1 when the Fed Funds Target Rate drops by at least ½ point.  Score a -1 when the rate rises by at least ½ point.

bondIndex$fedFund <- na.spline(getSymbols("DFF", src = "FRED", from = fiveYearsAgo, auto.assign = FALSE),na.rm = TRUE)
print (bondIndex)
bondIndex$fedFundlow <- runMin(bondIndex$fedFund,runLength)
bondIndex$fedFundhigh <- runMax(bondIndex$fedFund,runLength)

bondIndex$score <- ifelse(bondIndex$fedFund[,c(1)] >= (bondIndex$fedFundlow + 0.5), bondIndex$score + 1, bondIndex$score)
bondIndex$score <- ifelse(bondIndex$fedFund[,c(1)] <= (bondIndex$fedFundhigh - 0.5), bondIndex$score - 1, bondIndex$score)

