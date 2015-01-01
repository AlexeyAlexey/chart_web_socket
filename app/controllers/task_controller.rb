class TaskController < WebsocketRails::BaseController
  include TaskHelper
  before_filter :authenticate_user!
  def create
    begin
      task = message
      raise "Set date" if message["date_since"] == ""
      date_since = Date.strptime(message["date_since"], '%m/%d/%Y')
      #task = Task.new message
  
      RequestToGithub.perform_async date_since, message["access_token"], message["repo"]

      WebsocketRails[:tasks].trigger :create, []
    rescue Exception => msg
      task[:error] = msg.message
      
      trigger_failure task
      #send_message :create, task, namespace: :tasks
    end

    #if task.save
      #WebsocketRails[:tasks].trigger :create, []
    #else
      #send_message :create, task, namespace: :tasks
    #end

  end
end