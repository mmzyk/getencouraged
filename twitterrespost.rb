require 'rubygems'
require 'twitter'
require File.expand_path(File.join(File.dirname(__FILE__), 'configuration.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'blacklist.rb'))

# What this script does: Hits the twitter api for the account specified and pulls the replies
# sent to that account and retweets them, appling some new formatting, from the account
# The script will write the id of the last reply to a file and check for the file
# each time the script is run, using the id it finds as a param to the twitter api
# so only replies since that id are returned
# Author -- Mark Mzyk
   
def read_last_id
  last_id = nil
  if File.exists?("idstore")
    f = File.open("idstore", "r") 
    last_id = f.readline
  end
  last_id
end  

def write_last_id(id)
  File.open("idstore", "w") do |f|
    f.puts id
  end  
end  

def get_replies(id, account)
  if id == nil
    replies = account.replies
  else  
    options = {:since_id => id}
    replies = account.replies(options)
  end
end  

#main
id = read_last_id
config = Configuration.read_config
client = Twitter::HTTPAuth.new(config['username'],config['password'])
account = Twitter::Base.new(client)
blacklist = Blacklist.new
replies = get_replies(id, account)

# Twitter returns replies from newest to oldest, but want to retweet the oldest first
replies.reverse!
replies.each do |r|
  if blacklist.eligible_to_retweet(r.text, r.user.screen_name)
    text = blacklist.strip_username(r.text, config['username'])
    text = blacklist.strip_unwanted_phrases(text)
    text << ' (@' + r.user.screen_name + ')'
    account.update(text)
  end
  write_last_id(r.id)
end
