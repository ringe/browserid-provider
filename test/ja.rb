require "test/unit"
require "json"
require "rack"
require "rack/test"
require "mocha"
require "browserid-provider"
require "ruby-debug"
require "thin"
require "warden"

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

    assert last_response.content_type == "application/json", "Content type was #{last_response.content_type} but must be application/json"

    json = JSON.parse(last_response.body)
    assert json.keys == ["public-key", "authentication", "provisioning"], "Malformed JSON response, see https://eyedee.me/.well-known/browserid for example data"

    assert json["public-key"].keys == ["algorithm","n","e"], "Invalid public key provided, see https://wiki.mozilla.org/Identity/BrowserID"
  end

  def test_get_whoami
    BrowserID::Provider.expects(:get_user).stubs(:email).returns("a@b.com")
    get BrowserID::Config.new.whoami_path
    assert last_response.ok?
  end
end

#Rack::Handler::Thin.run BrowserID::Provider.new, :Port => 3000
