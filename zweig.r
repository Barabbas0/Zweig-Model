#install.packages('quantmod', repos="http://cran.rstudio.com/")
require("quantmod")

# Get Dow Jones 20 Bond Price Index data from Google
# Scratch that. Use LQD as a liquid equivalent
bondIndex <- na.omit(getSymbols("LQD",src="google",auto.assign = FALSE))

# get S&P 500 data from FRED
sp500 <- na.omit(getSymbols("SP500",src = "FRED",from = "1949-12-31",auto.assign = FALSE))

# add 200 day moving average
sp500$ma <- runMean(sp500[,1], n=200)

# Score a +1 when the Index rises from a bottom price low by 0.6%.  Score a -1 when the index falls from a peak price by 0.6%.

low <- min(bondIndex[paste(format(Sys.Date()-360, format="%Y-%m-%d"), '::')])

print (low)