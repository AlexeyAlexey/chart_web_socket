module TaskHelper
  def web_socket()
  	Thread.new do
      sleep 10
      puts "1 Spawnling"
      
      WebsocketRails[:tasks].trigger :create, {name: "data_object"}
      #WebsocketRails::Synchronization.shutdown!
    end
  end
end
