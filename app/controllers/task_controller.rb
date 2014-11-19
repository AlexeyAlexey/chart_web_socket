class TaskController < WebsocketRails::BaseController
  before_filter :authenticate_user!
  def create
  	byebug
    task = Task.new message
    if task.save
      send_message :create_success, task, namespace: :task
    else
      send_message :create_fail, task, namespace: :task
    end
  end
end