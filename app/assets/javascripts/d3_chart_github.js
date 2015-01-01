function create_d3_chart_github(id_chart, data_origin, filter, width_chart, height_chart) {
    var data = $.extend(true, [], data_origin );

    var legend_color = set_color_legend(data);
    //alert(JSON.stringify(legend_color))
    //filter data
    if(typeof filter == "undefined"){filter = []}
    if(filter.length != 0){
      $.each(data, function(inex, object){
        $.each(filter, function(index, el_for_delete){
          delete object[el_for_delete]
        });        
      });
    };
    // set color
    var margin = {top: 40, right: 40, bottom: 100, left: 40},
        width = width_chart - margin.left - margin.right,
        height = height_chart - margin.top - margin.bottom;
  //Set up scales
    d3.select("div#"+id_chart).selectAll("*").remove();
    
    var color_arr = new Array();
    $.each(data[data.length - 1], function(key, value){
      if(value != "color"){ color_arr.push(value);};
    });

    
    var color = d3.scale.ordinal()
          .range(color_arr);
        //.range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);
  
    data.pop();
    
    //d3.keys(data[0]).filter(function(key) { return key !== "time"; });
    //["Not Found Lable","category - install","status - accepted","type - bug","category - API","category - other","status - duplicate","status - feedback"]
    color.domain(d3.keys(data[0]).filter(function(key) { return key !== "time"; }));
    data.reverse();

    //max value
    var max = 0;
    data.forEach(function(d) {
      max_i = 0;
      for(var key in d){
        if(key != "time"){ max_i += +d[key]; };
      };
      if(max < max_i){max = max_i};
    });
    
   // alert(d3.time.day.offset(new Date(data[data.length-1].time),8));
    var oneWeeks = 1000 * 60 * 60 * 24 * 7;
    var start_date = new Date(new Date(data[data.length-1].time).getTime() - oneWeeks);

    var xScale = d3.scale.ordinal()
      .rangeRoundBands([0, width], .1);

    var yScale = d3.scale.linear()
        .domain([0, max])
        .rangeRound([height, 0]);

    var xAxis = d3.svg.axis()
        .scale(xScale)
        .orient("bottom")
        .ticks(d3.time.week,1)
        .tickFormat(d3.time.format("%Y-%m-%d"));

    var yAxis = d3.svg.axis()
         .scale(yScale)
         .orient("left")
         .ticks(10);

   xScale.domain(data.map(function(d) { return new Date(d.time)}));
    
    //var chart_exist = d3.select(id_chart);
    //if(chart_exist[0][0] == null){chart_exist.remove();};
    var point, p;
    var svg = d3.select("div#" + id_chart)
          .append("svg")
          .attr("id", id_chart)
          .attr("width", width + margin.left + margin.right)
          .attr("height", height + margin.top + margin.bottom)
          .append("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
    
    svg.on("mouseover", function(d, i){
      point = d3.mouse(this)
      p = {x: point[0], y: point[1] };

    })

    svg.append("g")
          .attr("class","x axis")
          .attr("transform", "translate(0," + height + ")")
          .style("font-size", xScale.rangeBand()/7 + "px")
          .call(xAxis);

    svg.append("g")
      .attr("class","y axis")
      .style("font-size", xScale.rangeBand()/7 + "px")
      .call(yAxis);

    //bars
    data.forEach(function(d) {
      var y0 = 0;
      d.bars = color.domain().map(function(name) {return {name: name, y0: y0, y1: y0 += +d[name]}; });
      d.total = d.bars[d.bars.length - 1].y1;
    });
    //alert("d = " + JSON.stringify(data));
  
    var bar = svg.selectAll(".time")
      .data(data)
      .enter()
      .append("g")
      .attr("class", "bar")
      .attr("transform", function(d) {return "translate(" + xScale(new Date(d.time)) + ",0)"; })
      .on('click', function(d_column, i) {
        //alert(JSON.stringify(d) + " " +i);
        var currentBar = svg.select(".currentBar");
        if(currentBar[0][0] == null){
          
        
          var legend_window = svg.append("svg")
                .attr("class", "currentBar")
                .selectAll(".legend_window")
                .data(color.domain().slice().reverse())
                .enter().append("g")
                .attr("class", "legend_window")
                .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });
          
          legend_window.append("rect")
              .attr("x", p.x + 10)
              .attr("y", p.y)
              .attr("width", 18)
              .attr("height", 18)
              .style("fill", color);

          legend_window.append("text")
              .attr("x", p.x + 10)
              .attr("y", p.y)
              .attr("dx", "-.35em")
              .attr("dy", "1.35em")
              .style("text-anchor", "end")
              .text(function(d) { return d_column[d] + " - " + d; });
          
          var svg_legend_window = svg.select(".currentBar");
          //Get auto value element
          var width = svg_legend_window.node().getBBox().width,
              height = svg_legend_window.node().getBBox().height,
              x = svg_legend_window.node().getBBox().x,
              y = svg_legend_window.node().getBBox().y;

          svg_legend_window.insert("rect",":first-child")
            .attr("width", width + 20)
            .attr("height", height + 20)
            .attr("x", x - 10)
            .attr("y", y - 10)
            .attr("fill", "#00E540")
            .attr("rx", 10)
            .attr("ry", 10);
        }
        else{
          currentBar.remove();
          //svg.selectAll(".legend_window").remove();
        };
        
      })

        //alert(JSON.stringify(this));
        //bar.selectAll("rect").remove();

    bar.selectAll("rect")
      .data(function(d) {return d.bars; })
      .enter()
      .append("rect")
      .attr("width", xScale.rangeBand())
      .attr("y", function(d) {return yScale(d.y1); })
      .attr("height", function(d) {return yScale(d.y0) - yScale(d.y1);})
      .style("fill", function(d) {return color(d.name); });
      
    //legend
    var dx_legend = 0, dy_legend = 0;
    var x_square_legend = xScale.rangeBand()/7, y_square_legend = xScale.rangeBand()/7;

    var color_legend = d3.scale.ordinal()
          .range(legend_color["color"]);
    color_legend.domain(legend_color["legend_name"]);

    var legend = svg.append("svg")
      .attr("width", width)
      .attr("height", margin.bottom)
      .attr("y", (height + margin.bottom/2))
      .selectAll(".legend")
      .data(color_legend.domain().slice().reverse())
      .enter()
      .append("g")
      .attr("class", "legend")
      .attr("transform", function(d, i) { 
          dx_legend += (d.length+x_square_legend)*5;
          if(dx_legend >= width){dx_legend = (d.length+x_square_legend)*5; dy_legend += (y_square_legend + 5)};
          return "translate(" + dx_legend + "," + dy_legend + ")"; 
        })
      .on('click', function(d, i) {  
        
        
        if(array_include(filter, this["__data__"])){
          filter.splice(index_element(filter, this["__data__"]), 1)
        }
        else{
          filter.push(this["__data__"]);
        };
        create_d3_chart_github(id_chart, data_origin, filter, width_chart, height_chart);
        //chart("chat2" , clone, "category - command"); 
        //alert(this.attr("fill", "blue"))
      });

    
    legend.append("rect")
        .attr("x", 0)
        .attr("width", x_square_legend)
        .attr("height", y_square_legend)
        .style("fill", color_legend);

    legend.append("text")
        .attr("x", 0)
        .attr("dx", "-.35em")
        .attr("y", x_square_legend/2)
        .attr("dy", ".35em")
        .style("text-anchor", "end")
        .style("font-size", xScale.rangeBand()/7 + "px")
        .text(function(d) { return d; });
    
  };

  function set_color_legend(data){
    var legend_color = {};
    var color_arr_a = new Array();
    $.each(data[data.length - 1], function(key, value){
      if(value != "color"){ color_arr_a.push(value);};
    });
    legend_color["color"] = $.extend(true, [], color_arr_a );
    legend_color["legend_name"] = d3.keys(data[0]).filter(function(key) { return key !== "time"; });
    return legend_color;
  };

  function array_include (array, element){
    var inlude = false;
    $.each(array, function(index, value){
        if(value == element){inlude = true;};
    });
    return inlude;
  };

  function index_element(array, el_name){
    var index_el = -1;
    $.each(array, function(index, value){
        if(value == el_name){index_el = index;};
    });
    return index_el;
  };