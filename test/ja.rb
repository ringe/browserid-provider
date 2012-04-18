require "test/unit"
require "json"
require "rack"
require "rack/test"
require "browserid-provider"
require "ruby-debug"
require "thin"

class MyTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    BrowserID::Provider.new
  end

  def test_get_root
    get "/"
    assert last_response.status == 404, "BrowserID Provider should not respond to root"
  end

  def test_get_well_known_browserid
    get "/.well-known/browserid"
    if last_response.content_type != "application/json"
      raise "Content type of /.well-known/browserid was #{last_response.content_type} but must be application/json"
    else
      json = JSON.parse(last_response.body)
    end
  end
end

#Rack::Handler::Thin.run BrowserID::Provider.new, :Port => 3000
