# Zweig-Model
This is a demo/learning attempt at R. To run, simply execute Zweig.r. I still need to get it to output to a web service (hence the "Shiny" stuff). However, the model appears to be working correctly, retrieving and computing data from FRED (Federal Reserve Economic Data) and Yahoo/Google Finance.

For detailed info on how the model works, please read http://www.cmgwealth.com/how-to-track-the-zweig-bond-model/
TL;DR, Get daily data from FRED and G/YFinance, do some maths to get a value between -5 and 5 every day. That number corresponds to whether your bonds should be long or short duration. The idea is not to outperform in good times, rather to protect from the downside in bad times, allowing outperformance in the long term.
