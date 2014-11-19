# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  success = (task) ->
    alert("Created: " + task.name)

  failure = (task) ->
    alert("failure")
    alert("Faild to create Production: " + task.name)
  
  $(document).ready () -> 
  	`var dispatcher`
  	task = 
      name: 'Start taking advantage of WebSocket'
      completed: false

    $("a#connect_web_socket").bind 'click', () ->
      alert("connect_web_socket");
      `dispatcher = new WebSocketRails('0.0.0.0:3000/websocket')`
      dispatcher.bind 'task.create_success', success
    
    $('a#send_message').bind 'click', () ->
      alert("send_message")
      dispatcher.trigger 'task.create', task
    

  