require 'test/unit'
require 'rack/test'
ENV['RACK_ENV'] = 'test'
require 'revision_zero'
module RevisionZero
  class AppTest < Test::Unit::TestCase
    include Rack::Test::Methods
    
    def app
      App.new
    end
    
    def test_get_on_public_content 
      get '/images/mail.png'
      assert last_response.ok?
      assert "image/png", last_response.content_type
    end
    
    def test_get_on_root
      get '/'
      assert last_response.ok?
      assert_match /text\/html/, last_response.content_type 
      assert_match /Revision\-Zero.org/, last_response.body
      assert_no_match /analytics/, last_response.body
    end
    
    def test_each_page_is_ok
      app.writings.each{|w|
        puts "Visiting /#{w.identifier}"
        get "/#{w.identifier}"
        assert last_response.ok?
        assert_match /text\/html/, last_response.content_type 
      }
    end
    
    def test_pages_are_also_indexable 
      app.writings.each_with_index{|w, i|
        puts "Visiting /#{i}"
        
        # get by index
        get "/#{i}"
        assert last_response.ok?
        ith_body = last_response.body
        
        # get by name
        get "/#{w.identifier}"
        named_body = last_response.body
        
        assert_equal named_body, ith_body
      }
    end
    
    def test_get_on_unexisting
      get '/not_a_writing'
      assert !last_response.ok?
      assert_equal 404, last_response.status
    end
    
  end # class AppTest
end # module RevisionZero