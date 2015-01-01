class Task < ActiveRecord::Base

  def github_request
    #WebsocketRails[:tasks].trigger :create, {"name": "data_object"}
  end
end
