class Blacklist
  
  def initialize
    read_blacklists
  end  
  
  def read_blacklists 
   @phrase_blacklist = read_list(get_phrase_blacklist, [])
   @user_blacklist = read_list(get_user_blacklist, [])
   @unwanted_phrases = read_list(get_unwanted_phrases_list, [])
  end
  
  def strip_username(text, username)
    text.gsub(/@#{username}/i, '')
  end

  def get_phrase_blacklist
    File.expand_path(File.join(File.dirname(__FILE__), 'phrase_blacklist.app'))
  end  

  def get_user_blacklist
    File.expand_path(File.join(File.dirname(__FILE__), 'user_blacklist.app'))
  end  

  def get_unwanted_phrases_list
    File.expand_path(File.join(File.dirname(__FILE__), 'unwanted_phrases.app'))
  end

  def read_list(listFile, listArray)
    if File.exists?(listFile)
      f = File.open(listFile)
      begin
        while (line = f.readline)
          listArray << line.chomp
        end  
      rescue EOFError
        f.close
      end     
    end
    listArray
  end

  def strip_unwanted_phrases(text)
    if !@unwanted_phrases.empty?
      @unwanted_phrases.each { |p| text = text.gsub(p, '') }
    end
    text   
  end  

  def phrase_blacklisted(text)
    @phrase_blacklist.each do |v| 
      matches = text.scan(v)
      if matches.length > 0
        return false
      end      
    end
    true  
  end
  
  def user_blacklisted(username)
    @user_blacklist.each do |u|
      if u == username
        return false
      end
    end
    true     
  end    
  
  def check_if_spam(text)
    eligible = true
    matches = text.scan('@')
    if matches.length >= 3
      eligible = false
    end
    eligible  
  end
  
  def eligible_to_retweet(text, username)
    eligible = check_if_spam(text)
    eligible = phrase_blacklisted(text) if eligible
    eligible = user_blacklisted(username) if eligible
    eligible
  end
  
end

