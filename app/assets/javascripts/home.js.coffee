# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->    
  $(document).ready () ->
   global = {} 
   success = (response) ->
    alert("Created: " + response)

   failure = (response) ->
    alert("Faild to create Production: " + response.error)
    
   response_from_server = (response) ->
    create_d3_chart_github("create_d3_chart_github", response, [], 800, 400) if response.length != 0

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






    

  