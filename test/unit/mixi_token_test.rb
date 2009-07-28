require File.dirname(__FILE__) + '/../test_helper'

module MixiTokenTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :mixi_tokens
      end
    end
  end
  
  define_method('test: mixi_token はtokenカラムは必須') do 
    assert_difference "MixiToken.count", 1 do
      mixi_token = MixiToken.create({:token => "aaaa"})
    end
    
    assert_difference "MixiToken.count", 0 do
      mixi_token = MixiToken.create({:token => ""})
    end
    
  end
  
end