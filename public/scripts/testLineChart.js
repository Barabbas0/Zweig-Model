var Fred = require('fred-api');
var apiKey = process.env.FRED_KEY;
var fred = new Fred(apiKey);

fred.getSeries({series_id: 'GNPCA'}, function(error, result) {
    console.log(result)
});

//TODO: Populate labels and get data from fedSeriesList.csv

var lineChartData = {
	labels : ["Fed Funds","1 Month","3 Month","6 Month","1 Year","2 Year","3 Year","5 Year","7 Year","10 Year","20 Year","30 Year"],
		datasets : [
		    {
				label: "Treasury Curve",
				fillColor : "rgba(220,220,220,0.2)",
				strokeColor : "rgba(220,220,220,1)",
				pointColor : "rgba(220,220,220,1)",
				pointStrokeColor : "#fff",
				pointHighlightFill : "#fff",
				pointHighlightStroke : "rgba(220,220,220,1)",
				data : []
			}
		]
	}
window.onload = function(){
	var ctx = document.getElementById("canvas").getContext("2d");
	window.myLine = new Chart(ctx).Line(lineChartData, {
		responsive: true
	});
}