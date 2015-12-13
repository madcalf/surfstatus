'use strict';
/*
 * START
 */

// var canvas = document.querySelector( ".waves__canvas" );
// if (canvas) {

//   var options = {
//     color: "rgba(235,67,41,.1)",
//     waveAmplitude: 30,
//     waveRadius: 200,
//     waveElasticity: 0.75,
//     waveStrength: 0.01,
//     waveMouse: 40,
//     waveMax: 100,
//     waveComeUp: function() {},
//     waveRiseSpeed: 15,
//     lineWidth: 5,
//     waveLength: 100,
//     distance: 20
//   };

//   var app = new Canvas( canvas, size );

//   window.addEventListener( "resize", function() {
//     app.setSize( window.innerWidth, window.innerHeight );
//   }, false );

// }

/*
  Surf height description
*/

var directions = document.querySelectorAll('.directions__direction');

if (directions) {
  for (var i = 0; i < directions.length; i ++) {
    var thisBreaks = directions[i].querySelectorAll('.surfbreak');

    // SET DESCRIPTIVE SURF CONDITIONS
    var thisAverage = directions[i].getAttribute('data-height-mean');
    var setSurfConditions = function(surfConditions) {
      directions[i].querySelector('.direction__height').innerHTML = surfConditions;
    };
    if (thisAverage < 1) {
      setSurfConditions('flat');
    } else if (thisAverage >= 1 && thisAverage < 2) {
      setSurfConditions('small');
    } else if (thisAverage >= 2 && thisAverage < 3) {
      setSurfConditions('not bad');
    } else if (thisAverage >= 3 && thisAverage < 5) {
      setSurfConditions('good');
    } else if (thisAverage >= 5 && thisAverage < 7) {
      setSurfConditions('firing');
    } else if (thisAverage >= 7) {
      setSurfConditions('massive');
    }
  }

  /*
    CREATE CAROUSELS
  */

  var width = 800,
      widthSegment = (width/5),
      height = 500,
      multiplier = 150;

  var shoreDirections = ['north','west','east','south'];
  var tideGraphs = document.querySelectorAll('.tide__graph');
  for (var tideIndex = 0; tideIndex < tideGraphs.length; tideIndex++) {
    var tidesData     = tideGraphs[tideIndex].getAttribute('data-tides').replace('[','').replace(']','').split(',');
    var timesData     = tideGraphs[tideIndex].getAttribute('data-times').replace('["','').replace('"]','').split('","');
    var timeLabelData = tideGraphs[tideIndex].getAttribute('data-time-labels').replace('["','').replace('"]','').split('","');

    var lineData = [ { "x": 0,              "y": 500},
                     { "x": 0,              "y": tidesData[0]},
                     { "x": widthSegment,   "y": tidesData[1]},
                     { "x": widthSegment*2, "y": tidesData[2]},
                     { "x": widthSegment*3, "y": tidesData[3]},
                     { "x": widthSegment*4, "y": tidesData[4]},
                     { "x": widthSegment*5, "y": tidesData[5]}
                   ];

    var svgContainer = d3.select(".tide__graph[data-shore="+ shoreDirections[tideIndex] +"]").attr('viewBox', '0 0 800 500');

    var line = d3.svg.line();

    var tideFunction  = d3.svg.line()
                              .x(function(d) {
                                return d.x;
                              })
                              .y(function(d) {
                                d = (d.y * multiplier) + (height/2);
                                return d;
                              }).interpolate("monotone");
    var tideAttributes  = svgContainer.append("path").attr('d', tideFunction(lineData));
    var graphMarks      = svgContainer.append("line").attr('x1', widthSegment).attr('y1', 0).attr('x2', widthSegment).attr('y2', 500);
    var graphMarks1     = svgContainer.append("line").attr('x1', widthSegment*2).attr('y1', 0).attr('x2', widthSegment*2).attr('y2', 500);
    var graphMarks2     = svgContainer.append("line").attr('x1', widthSegment*3).attr('y1', 0).attr('x2', widthSegment*3).attr('y2', 500);
    var graphMarks3     = svgContainer.append("line").attr('x1', widthSegment*4).attr('y1', 0).attr('x2', widthSegment*4).attr('y2', 500);
    var graphTime      = svgContainer.append("text").attr('x', widthSegment-30).attr('y',   500).text(timesData[0]);
    var graphTime1     = svgContainer.append("text").attr('x', widthSegment*2-30).attr('y', 500).text(timesData[1]);
    var graphTime2     = svgContainer.append("text").attr('x', widthSegment*3-30).attr('y', 500).text(timesData[2]);
    var graphTime3     = svgContainer.append("text").attr('x', widthSegment*4-30).attr('y', 500).text(timesData[3]);
    var graphLabel      = svgContainer.append("text").attr('x', widthSegment-35).attr('y',   60).text(timeLabelData[0]);
    var graphLabel1     = svgContainer.append("text").attr('x', widthSegment*2-35).attr('y', 60).text(timeLabelData[1]);
    var graphLabel2     = svgContainer.append("text").attr('x', widthSegment*3-35).attr('y', 60).text(timeLabelData[2]);
    var graphLabel3     = svgContainer.append("text").attr('x', widthSegment*4-35).attr('y', 60).text(timeLabelData[3]);
    // var circle = svgContainer.append("line")
    //  8                         .attr("x1", 5)
    //  9                         .attr("y1", 5)
    // 10                         .attr("x2", 50)
    // 11                         .attr("y2", 50);
  }

  /*
    CREATE CAROUSELS
  */
  var wallopEl01 = document.querySelector('.Wallop-north');
  var slider01 = new Wallop(wallopEl01);
  wallopEl01.addEventListener('click', function(){
    slider01.next();
  })
  var wallopEl02 = document.querySelector('.Wallop-west');
  var slider02 = new Wallop(wallopEl02);
  wallopEl02.addEventListener('click', function(){
    slider02.next();
  })
  var wallopEl03 = document.querySelector('.Wallop-east');
  var slider03 = new Wallop(wallopEl03);
  wallopEl03.addEventListener('click', function(){
    slider03.next();
  })
  var wallopEl04 = document.querySelector('.Wallop-south');
  var slider04 = new Wallop(wallopEl04);
  wallopEl04.addEventListener('click', function(){
    slider04.next();
  })

}