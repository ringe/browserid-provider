require "test/unit"
require "rack"
require "rack/test"
require "browserid-provider"
require "ruby-debug"
require "thin"

class MyTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    BrowserID::Provider::App.new
  end

  def test_get_root
#    authorize "bryan", "secret"
    get "/"
    puts last_response.data
#    follow_redirect!
#
#    assert_equal "http://example.org/redirected", last_request.url
    assert last_response.ok?
  end

end

Rack::Handler::Thin.run BrowserID::Provider::App.new, :Port => 3000
