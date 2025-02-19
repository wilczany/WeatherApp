Chartkick.options = {
  height: "250px",
  # colors: [ "#4258ff", "#adadad" ]
  colors: [ "#66D1FF", "#00d1b2", "#4158fe" ],
  legend: "top",
  library: {
    chart: {
      backgroundColor: "transparent"
    },
    yAxis: {
      gridLineColor: "rgba(255, 255, 255, 0.4)"
    },
    xAxis: {
      type: "datetime",
      labels: {
        format: "{value:%d %m %y - %H:%M}"
      }
    },
    tooltip: {
      xDateFormat: "%d %m %y - %H:%M",
      pointFormat: "{series.name}: {point.y}"

    }
  }

}
