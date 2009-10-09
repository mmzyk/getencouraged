require 'rubygems'
require 'twitter'
require 'mongo'
include Mongo
require File.expand_path(File.join(File.dirname(__FILE__), 'configuration.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'blacklist.rb'))

class Repost
  
  def initialize
    @db = nil
  end  
  
  # What this class does: Hits the twitter api for the account specified and pulls the replies
  # sent to that account and retweets them, appling some new formatting, from the account
  # The class will write the id of the last reply to a file and check for the file
  # each time the class is run, using the id it finds as a param to the twitter api
  # so only replies since that id are returned
  # Author -- Mark Mzyk
  
  #store the last id as it's own collection in mongo instead of in a flat file ...
  
  #should I insert a primary key factory (see mongo ruby driver on github) that uses tweet numbers?
  #then I could look up by tweet number -> or a simpler thing to do would just to be a primary key factory that always increments by one
  
  def open_mongo
    #if @db not nil
    #  @db
    #else  
    #  @db = Connection.new.db('twitter_tweets') 
  end  
  
  def open_id_collection
    #if @ids not nil
    #  @ids
    #else
    #  @ids = open_mongo.collection('ids')
    #end
  end  
  
  def read_last_id
    db = Connection.new.db('twitter_tweets')
    ids = db.collection('ids')
    
    #this works, but a capped collection might be better, then the space remains constant
    id = ids.find_one({}, :sort => [{'id' => -1}] )
    
    puts 'last id *****'
    puts id['id']
    puts ''
    
    id['id']
  end  

  def write_last_id(id)
    db = Connection.new.db('twitter_tweets')
    ids = db.collection('ids')
    ids.insert('id' => id)
  end  

  def write_tweets(tweet)
    
    # save tweets to mongodb
    db = Connection.new.db('twitter_tweets')
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

    # Twitter returns replies from newest to oldest, but want to retweet the oldest first
    retweets.reverse!

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
