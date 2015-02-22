# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->    
  $(document).ready () ->
   
   success = (response) ->
    alert("Created: " + response)

   failure = (response) ->
    alert("Faild to create Production: " + response.error)
    
   response_from_server = (response) ->
    window.response_d3_chart = response
    chart_size = 
     "width": 900 
     "height": 800
     "x_text_size_px": 12
     "y_text_size_px": 12
     "bottom_lg_text_size_px": 12
     "bottom_lg_rect_size_px": 12
     "window_lg_text_size_px": 12
     "window_lg_rect_size_px": 12
    create_d3_chart_github("create_d3_chart_github", response, [], chart_size) if response.length != 0

   task = 
    name: 'Start taking advantage of WebSocket'
    completed: false

   $("#connect_web_socket").bind 'click', () ->
    window.dispatcher = new WebSocketRails('0.0.0.0:3000/websocket')
    window.channel = window.dispatcher.subscribe('tasks')
  
    window.dispatcher.on_open = (data) ->
     alert('Connection has been established')

    window.channel.bind 'create', response_from_server    

   $('#build_chart').bind 'click', () ->
    alert(window.dispatcher.state)
    if typeof window.dispatcher == "undefined"
     alert("Please connect")
     return
    if window.dispatcher.state == "disconnected"
     alert("Please connect")
     return

    task["date_since"] = $("#datepicker").val()
    task["access_token"] = $("#access_token").val()
    task["repo"] = $("#repo").val()

    window.dispatcher.trigger 'tasks.create', task, success, failure

   $("#datepicker").datepicker()

   $("#resize").bind 'click', (eventObject) ->
     chart_size = {}
     chart_size["width"] = $("#width_size").val()
     chart_size["height"] = $("#height_size").val()
     chart_size["x_text_size_px"] = $("#x_text_size_px").val()
     chart_size["y_text_size_px"] = $("#y_text_size_px").val()
     chart_size["bottom_lg_text_size_px"] = $("#bottom_lg_text_size_px").val()
     chart_size["bottom_lg_rect_size_px"] = $("#bottom_lg_rect_size_px").val()
     chart_size["window_lg_text_size_px"] = $("#window_lg_text_size_px").val()
     chart_size["window_lg_rect_size_px"] = $("#window_lg_rect_size_px").val()


     chart_div = $("#create_d3_chart_github")
     chart_div.css({"z-inex": 1, "background-color": "white"}) 
     create_d3_chart_github("create_d3_chart_github", window.response_d3_chart, [], chart_size) if window.response_d3_chart.length != 0






    

  