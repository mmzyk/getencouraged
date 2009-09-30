require 'blacklist'
require 'test/unit'

class Test_Blacklist < Test::Unit::TestCase
    
    def test_strip_username
      blacklist = Blacklist.new
      text = blacklist.strip_username 'this is a test @mark', 'mark'    
      assert_equal 'this is a test ', text, 'Did not receive expected string'      
    end  
    
    def test_strip_unwanted_phrases_empty
      blacklist = Blacklist.new
      blacklist.instance_variable_set :@unwanted_phrases, []
      text = blacklist.strip_unwanted_phrases 'this is a test'
      assert_equal 'this is a test', text, 'Did not receive expected string'
    end  
    
    def test_strip_unwanted_phrases_one_phrase
      blacklist = Blacklist.new
      blacklist.instance_variable_set :@unwanted_phrases, ['test']
      text = blacklist.strip_unwanted_phrases 'this is a test'
      assert_equal 'this is a ', text, 'Did not receive expected string'
    end
    
    def test_strip_unwanted_phrases_two_phrases
      blacklist = Blacklist.new
      blacklist.instance_variable_set :@unwanted_phrases, ['this', 'test']
      text = blacklist.strip_unwanted_phrases 'this is a test'
      assert_equal ' is a ', text, 'Did not receive expected string'
    end  
    
    def test_phrase_blacklisted_phrase_not_found
      blacklist = Blacklist.new
      blacklist.instance_variable_set :@phrase_blacklist, ['dog']
      eligible = blacklist.phrase_blacklisted 'this is a test'
      assert eligible, 'Text blacklisted that shouldnt have been'
    end 
    
    def test_phrase_blacklisted_one_phrase 
      blacklist = Blacklist.new
      blacklist.instance_variable_set :@phrase_blacklist, ['this is']
      eligible = blacklist.phrase_blacklisted 'this is a test'
      assert_equal eligible, false, 'Text not blacklisted that should have been'
    end  
    
    def test_phrase_blacklisted_two_phrases 
      blacklist = Blacklist.new
      blacklist.instance_variable_set :@phrase_blacklist, ['not found', 'this is']
      eligible = blacklist.phrase_blacklisted 'this is a test'
      assert_equal eligible, false, 'Text not blacklisted that should have been'
    end
      
    def test_user_blacklisted_user_not_found
      blacklist = Blacklist.new
      blacklist.instance_variable_set :@user_blacklist, ['bob']
      eligible = blacklist.user_blacklisted 'dan'
      assert eligible, 'User blacklisted that should not have been'
    end    
    
    def test_user_blacklisted_one_user
      blacklist = Blacklist.new
      blacklist.instance_variable_set :@user_blacklist, ['bob']
      eligible = blacklist.user_blacklisted 'bob'
      assert_equal eligible, false, 'User not blacklisted that should not have been'
    end
      
    def test_user_blacklisted_two_users
      blacklist = Blacklist.new
      blacklist.instance_variable_set :@user_blacklist, ['bob', 'jim']
      eligible = blacklist.user_blacklisted 'jim'
      assert_equal eligible, false, 'User not blacklisted that should not have been'
    end
    
    def test_check_if_spam
      blacklist = Blacklist.new
      eligible = blacklist.check_if_spam 'this is not spam'
      assert eligible, 'Found to be spam when it should not have been'
    end
    
    def test_check_is_spam_one_at  
      blacklist = Blacklist.new
      eligible = blacklist.check_if_spam 'this is not spam @bob'
      assert eligible, 'Found to be spam when it should not have been'
    end
      
    def test_check_is_spam_two_ats  
      blacklist = Blacklist.new
      eligible = blacklist.check_if_spam 'this is not spam @bob, @dan'
      assert eligible, 'Found to be spam when it should not have been'
    end
        
    def test_check_is_spam_three_ats  
      blacklist = Blacklist.new
      eligible = blacklist.check_if_spam 'this is spam @bob, @dan, @jim'
      assert_equal eligible, false, 'Found to not be spam when it should not have been'
    end
      
      
      
end        


        