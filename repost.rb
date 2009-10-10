require 'rubygems'
require 'twitter'

require File.expand_path(File.join(File.dirname(__FILE__), 'configuration.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'blacklist.rb'))

require 'mongo'
include Mongo

class Repost
  
  def initialize
    @db = initialize_mongo
    @config = Configuration.read_config
    @blacklist = Blacklist.new
  end  
  
  def initialize_mongo
    db = Connection.new.db('twitter_tweets') 
  end  
  
  def open_id_collection
    ids = @db.create_collection('ids', :capped => true, :size => 1024, :max => 1)
  end  
  
  def open_tweet_collection
    tweets = @db.collection('tweets')
  end  
  
  def read_last_id
    ids_collection = open_id_collection
    id = ids_collection.find_one
    
    last_id = nil
    if id != nil
      last_id = id['id']
    end    
      
    last_id
  end  

  def write_last_id(id)
    ids_collection = open_id_collection
    ids_collection.insert('id' => id)
  end  

  def save_tweet(tweet)
    tweet_collection = open_tweet_collection
    tweet_collection << { :text => tweet.text, :user => tweet.user.screen_name, :id => tweet.id}
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

  def format_text(tweet_text, user_screen_name)
    text = @blacklist.strip_username(tweet_text, @config['username'])
    text = @blacklist.strip_unwanted_phrases(text)
    text << ' (@' + user_screen_name + ')'
  end  

  def twitter_account
    client = Twitter::HTTPAuth.new(@config['username'], @config['password'])
    account = Twitter::Base.new(client)
  end  

  def repost_tweets
    id = read_last_id
    account = twitter_account
    replies = get_replies(id, account)
    retweets = get_replies_to_retweet(replies, @config['number_to_tweet'])
    
    retweets.reverse! # Twitter returns replies from newest to oldest, but want to retweet the oldest first
    
    retweets.each do |tweet|
      if @blacklist.eligible_to_retweet(tweet.text, tweet.user.screen_name)
        text = format_text(tweet.text, tweet.user.screen_name)
        save_tweet(tweet)
        account.update(text)
      end  
      write_last_id(tweet.id)
    end
    
  end  

end

if __FILE__ == $0
  repost = Repost.new
  repost.repost_tweets
end  
