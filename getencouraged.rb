require 'rubygems'
require 'sinatra'
require 'twitter'
require File.expand_path(File.join(File.dirname(__FILE__), 'configuration.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'blacklist.rb'))

helpers do
  def get_auth
    Twitter::HTTPAuth.new(@config['username'],@config['password'])
  end
  
  def get_account
    if !defined? @base
      @base = Twitter::Base.new get_auth
    end
    @base  
  end  
  
  def get_replies
    get_account.replies
  end
  
  def get_reply_info(reply)
      reply_info = Hash.new
      reply_info['text'] = @blacklist.strip_username(reply.text, @config['username'])
      reply_info['text'] = @blacklist.strip_unwanted_phrases(reply_info['text'])
      reply_info['text'] = link_usernames(reply_info['text'])
      reply_info['id'] = reply.id
      reply_info['user'] = reply.user.screen_name
      reply_info['image_url'] = reply.user.profile_image_url
      reply_info['timestamp'] = Time.parse(reply.created_at).strftime("%A, %B %d at %I:%M %p")
      reply_info
  end
  
  def link_usernames(text)
    text.gsub(/@([a-zA-Z0-9_]+)/, '<a href="http://twitter.com/\1">@\1</a>' )
  end
      
  def pull_from_twitter  
    replies = get_replies
    reply_array = Array.new

    #The Twitter API limits this call to the last 20 replies
    1.upto(20) do
      if replies.length != 0
        reply = replies.shift
        if @blacklist.eligible_to_retweet(reply.text, reply.user.screen_name)
          reply_array << get_reply_info(reply)
        end  
      else
        break
      end
    end
  
    reply_array.reverse
  end
   
end  

get '/' do  
  @config = Configuration.read_config
  @blacklist = Blacklist.new
  @reply_array = pull_from_twitter
  
  # Dev & testing flag for analytics
  if @config['testing'] == 'true'
    @testing = true
  else 
    @testing = false
  end
        
  erb :index
end

