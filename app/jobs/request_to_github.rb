class RequestToGithub < ActiveJob::Base
  include Sidekiq::Worker
  queue_as :default
 
  def perform(*args)
  	date_since, github_access_token, github_repo = *args;
  	client = Octokit::Client.new(:access_token => github_access_token)
    user = client.user
    user.login

    repo = Octokit.repo github_repo
    sha_or_branch = 'master'

    commits_from_branch = client.commits_since(github_repo, date_since.to_s, sha_or_branch, per_page: 100)
    #"https://api.github.com/repos/rubygems/rubygems/commits?sha=master&?access_token=f8ab2db8e3a25149ce2d7c1e0f3e6008b9b747bc"

    if commits_from_branch.is_a?(Array)
      while client.last_response.rels[:next]
        last_response = client.get(client.last_response.rels[:next].href)
        commits_from_branch.concat(last_response) if last_response.is_a?(Array)    
      end
    end

    commit_issues = []
    commits_from_branch.each do |commit|
	    message = commit["commit"]["message"]
	    issues = []
	    labels = []
	    unless message.nil?
	      issues = commit["commit"]["message"].scan(/#(\d*)/).flatten
	      issues.delete("")
	    end

	    unless issues.nil?
	      commit_issue = {}
	      commit_issue[:sha] = commit["sha"]
	      commit_issue[:committer] = commit["commit"]["committer"]
	      commit_issue[:message] = commit["commit"]["message"]
	      commit_issue[:issues] = issues
	      commit_issue[:labels] = []

	      issues.each do |issue|
	        begin
	          response_lables = client.labels_for_issue('rubygems/rubygems', issue)
	        rescue
	          response_lables = []
	        end
	        if response_lables.empty?
	          commit_issue[:labels] << [{:url => "", :name => "Not Found Lable", :color => "000000"}]
	        else
	          commit_issue[:labels] << response_lables 
	        end
	      end
	      commit_issues << commit_issue
	    end
    end
	#commit_issue = {:sha=>"3fca8", 
	#                 :committer=>{:name=>"", :email=>"", :date=>2014-11-22 01:35:58 UTC}, 
	#                 :message=>"", :issues=>[111, ...], 
	#                 :labels => [[{:url => "", :name => "", :color => "000000"}, ...]}

	timestamp_commit_issues = {}
	commit_issues.each do |commit_issue|
	  time = commit_issue[:committer]["date"]
	  time_new = Time.new(time.year, time.month, time.day)
	  w_day = time_new.wday
	  start_week = time_new - w_day*60*60*24
	  timestamp = start_week.to_i

	  unless timestamp_commit_issues.key?(timestamp)
	    timestamp_commit_issues[timestamp] = []
	  end

	  timestamp_commit_issues[timestamp] << commit_issue
	end
	#timestamp_commit_issues = {timestamp: [{:sha=>"3fca8", 
	#                                        :committer=>{:name=>"", :email=>"", :date=>2014-11-22 01:35:58 UTC}, 
	#                                        :message=>"", :issues=>[111, ...], 
	#                                        :labels => [[{:url => "", :name => "", :color => "000000"}, ...]}
	#                         }


	hash_graph = {time: [], colors: {}}
	init_arr = []
	timestamp_commit_issues.length.times {|i| init_arr << 0}
	i = 0
	timestamp_commit_issues.each_pair do |timestamp, value|
	  hash_graph[:time] << Time.at(timestamp)
	  
	  value.each do |commit|
	  	commit[:labels].each do |labels|
	  	  labels.each do |label|
	  	  	name = label[:name]
	  	    unless hash_graph.key?(name)
	  	      hash_graph[name] = init_arr.clone
	  	    end
	  	    hash_graph[:colors][name] = "##{label[:color]}"
	        hash_graph[name][i] += 1
	  	  end      
	  	end
	  end
	  i += 1	
	end

	length = hash_graph[:time].length
	data = []
	length.times do |n| 
	  object_i = {} 
	  hash_graph.each_key do |key|
	  	unless key == :colors
	  	  object_i[key] = hash_graph[key][n]
	  	end
	  end
	  data << object_i
	end

	color = {time: :color}.merge(hash_graph[:colors])
	data << color
  	WebsocketRails[:tasks].trigger :create, data
  end
end