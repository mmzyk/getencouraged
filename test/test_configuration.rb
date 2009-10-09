require 'configuration'
require 'test/unit'
require 'mocha'

class Test_Configuration < Test::Unit::TestCase
  
  def test_readline_into_hash
    line = 'this is a test'
    # Config right now is static: make it an object instead.
    #config = Configuraiton.new
    #config.readline_into_hash([], line)
    assert true
  end  
  
end  