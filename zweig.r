#install.packages('quantmod', repos="http://cran.rstudio.com/")
require("quantmod")

startDate = Sys.Date() - (365 * 20)

###################
# Data collection #
###################
get90DayPaperRate <- function(){
    #######################################################
    # Step 1: get all relevant metrics
    paperRate <- getSymbols("DCPF3M", src = "FRED", auto.assign = FALSE) #Financial Paper Yield
    paperRate$nonFinancialYeild <- getSymbols("DCPN3M", src = "FRED", auto.assign = FALSE) #Non-financial Paper Yield
    paperRate$financialOutstanding <- getSymbols("DFINCP", src = "FRED", auto.assign = FALSE) #Financial Paper Outstanding
    paperRate$nonFinancialOutstanding <- getSymbols("DNFINCP", src = "FRED", auto.assign = FALSE) #Non-financial Paper Outstanding
    ########################################################
    # Step 2: Tidy/clean up
    paperRate <- na.spline(paperRate['2000::'])
    ########################################################
    # Step 3: Figure out weighing
    paperRate$totalOutstanding <- paperRate$financialOutstanding + paperRate$nonFinancialOutstanding
    paperRate$financialOutstanding <- paperRate$financialOutstanding / paperRate$totalOutstanding
    paperRate$nonFinancialOutstanding <- paperRate$nonFinancialOutstanding / paperRate$totalOutstanding
    #########################################################
    # Step 4: Calculate weighted mean
    paperRate$dailyRate <- (paperRate$DCPF3M * paperRate$financialOutstanding + paperRate$nonFinancialYeild * paperRate$nonFinancialOutstanding)
    #########################################################
    # Step 5: Return
    return(paperRate$dailyRate)
}
setUpData <- function(fromDate = startDate) {
    # Get Dow Jones 20 Bond Price Index data (LQD) from Google
    index <- getSymbols("LQD",src="google",from = fromDate, auto.assign = FALSE)[,c(0,4)]
    index$fedFund <- getSymbols("DFF", src = "FRED", from = fromDate, auto.assign = FALSE)
    merge(index$LQD.Close, index$fedFund, all = TRUE)
    
    index$AAA <- getSymbols("DAAA", src = "FRED", from = fromDate, auto.assign = FALSE)
    merge(index$LQD.Close, index$AAA, all = TRUE)
    
    index$paperRate <- get90DayPaperRate()
    merge(index$LQD.Close, index$paperRate, all = TRUE)
    
    index <- na.spline(index['2000::'])
    index$spread <- index$AAA - index$paperRate
    
    index$score <- 0
    
    return(index)
}

scoring <- function() {
    bondIndex <- setUpData()
    # Rule 1:
    # Score a +1 when the Index rises from a bottom price low by 0.6%.  Score a -1 when the index falls from a peak price by 0.6%.
    runLength = 365 # The rules don't state what a "bottom" price is. We're using the lowest price in the past year.
    
    bondIndex$low <- runMin(bondIndex$LQD.Close,runLength)
    bondIndex$high <- runMax(bondIndex$LQD.Close,runLength)
    
    bondIndex$score <- ifelse(bondIndex$LQD.Close > (bondIndex$low * 1.006), bondIndex$score + 1, bondIndex$score)
    bondIndex$score <- ifelse(bondIndex$LQD.Close < (bondIndex$high * .994), bondIndex$score - 1, bondIndex$score)
    
    # Rule 2:
    # Score a +1 when the Index rises from a bottom price low by 1.8%.  Score a -1 when the index falls from a peak price by 1.8%.
    
    bondIndex$score <- ifelse(bondIndex$LQD.Close > (bondIndex$low * 1.018), bondIndex$score + 1, bondIndex$score)
    bondIndex$score <- ifelse(bondIndex$LQD.Close < (bondIndex$high * .982), bondIndex$score - 1, bondIndex$score)
    
    # Rule 3:
    # Score a +1 when the Index crosses above it's 50 day moving average by 1%.  Score a -1 when the index crosses below it's 50 day moving average by 1%.
    
    bondIndex$fiftyDayMA <- SMA(bondIndex$LQD.Close,50)
    
    bondIndex$score <- ifelse(bondIndex$LQD.Close > (bondIndex$fiftyDayMA * 1.01), bondIndex$score + 1, bondIndex$score)
    bondIndex$score <- ifelse(bondIndex$LQD.Close < (bondIndex$fiftyDayMA * .99), bondIndex$score - 1, bondIndex$score)
    
    
    # Rule 4:
    # Score a +1 when the Fed Funds Target Rate drops by at least ½ point.  Score a -1 when the rate rises by at least ½ point.
    
    
    bondIndex$fedFundlow <- runMin(bondIndex$fedFund,runLength)
    bondIndex$fedFundhigh <- runMax(bondIndex$fedFund,runLength)
    
    bondIndex$score <- ifelse(bondIndex$fedFund[,c(1)] >= (bondIndex$fedFundlow + 0.5), bondIndex$score + 1, bondIndex$score)
    bondIndex$score <- ifelse(bondIndex$fedFund[,c(1)] <= (bondIndex$fedFundhigh - 0.5), bondIndex$score - 1, bondIndex$score)
    
    
    # Rule 5:
    # Score a +1 when the yield difference of AAA Corporate Bond Yield minus the yield on 90-day Commercial Paper Yield crosses above 0.6.
    # Score a -1 when the yield difference falls below -0.2.  Score it 0 for a neutral score between -0.2 and 0.6.
    bondIndex$score <- ifelse(bondIndex$spread >= 0.6, bondIndex$score + 1, bondIndex$score)
    bondIndex$score <- ifelse(bondIndex$spread <= -0.2,bondIndex$score - 1, bondIndex$score)
    
    return(bondIndex$score)
}

return(scoring())