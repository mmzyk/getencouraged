require 'rubygems'
require 'twitter'

require File.expand_path(File.join(File.dirname(__FILE__), 'configuration.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'blacklist.rb'))

require 'mongo'
include Mongo

class Repost
  
  def initialize
    @db = initialize_mongo
  end  
  
  def initialize_mongo
    db = Connection.new.db('twitter_tweets') 
  end  
  
  def open_id_collection
    ids = @db.create_collection('ids', :capped => true, :size => 1024, :max => 1)
  end  
  
  def read_last_id
    ids = open_id_collection
    id = ids.find_one
    
    last_id = nil
    
    if id != nil
      last_id = id['id']
    end    
      
    last_id
  end  

  def write_last_id(id)
    ids = open_id_collection
    ids.insert('id' => id)
  end  

  def save_tweets(tweet)
    # save tweets to mongodb
  end  

  def get_replies(id, account)
    if id == nil
      replies = account.replies
    else  
      options = {:since_id => id}
      replies = account.replies(options)
    end
  end  

  def get_replies_to_retweet(replies, number_to_tweet)
    if number_to_tweet == -1
      retweets = replies
    else  
      retweets = replies.last(number_to_tweet)
    end
  
    retweets
  end

  def repost_tweets
    id = read_last_id
    config = Configuration.read_config
    client = Twitter::HTTPAuth.new(config['username'],config['password'])
    account = Twitter::Base.new(client)
    blacklist = Blacklist.new
    replies = get_replies(id, account)
    retweets = get_replies_to_retweet(replies, config['number_to_tweet'])
    
    retweets.reverse! # Twitter returns replies from newest to oldest, but want to retweet the oldest first
    
    retweets.each do |r|
      if blacklist.eligible_to_retweet(r.text, r.user.screen_name)
        text = blacklist.strip_username(r.text, config['username'])
        text = blacklist.strip_unwanted_phrases(text)
        text << ' (@' + r.user.screen_name + ')'
        account.update(text)
      end
      write_last_id(r.id)
    end
    
  end  

end

if __FILE__ == $0
  repost = Repost.new
  repost.repost_tweets
end  
