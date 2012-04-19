require "test/unit"
require "json"
require "rack"
require "rack/test"
require "mocha"
require "browserid-provider"
require "ruby-debug"
require "warden"

class MyTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Warden::Test::Helpers
  attr_accessor :thisapp

  def app
    @thisapp = Rack::Builder.new do
      use Rack::CommonLogger
      use Rack::Session::Cookie
      use Warden::Manager do |manager|
        manager.default_strategies :basic
      end

      run BrowserID::Provider.new
    end
  end

  def test_get_root
    get "/"
    assert last_response.status == 404, "BrowserID Provider should not respond to root"
  end

  def test_get_well_known_browserid
    get "/.well-known/browserid"

    assert last_response.ok?
    assert_json_response

    # Test the JSON output
    json = JSON.parse(last_response.body)
    assert json.keys == ["public-key", "authentication", "provisioning"], "Malformed JSON response, see https://eyedee.me/.well-known/browserid for example data"
    assert json["public-key"].keys == ["algorithm","n","e"], "Invalid public key provided, see https://wiki.mozilla.org/Identity/BrowserID"
  end

  def test_get_whoami
    fake_user "mormor@example.org"
    get "/browserid/whoami"
    assert last_response.ok?
    assert_json_response
    assert last_response.body == '{"user":"mormor"}', "The whoami_path should return JSON with user name only, without domain"
  end

  def test_get_provision
    get "/browserid/provision"
    assert last_response.ok?
    assert last_response.body.include?("https://dev.diresworb.org/provisioning_api.js"), "The default provisions_api.js must be provided, see https://developer.mozilla.org/en/BrowserID/Primary/Developer_tips"
  end

  def test_post_certify
    get "/browserid/certify"
    assert last_response.status == 404, "Should only allow POST to /browserid/certify"

    fake_user "mormor@example.org"
    post "/browserid/certify", params = { "duration" => 2500, "pubkey" => "aasdcasd" }
    assert_json_response
    assert last_response.body =~ /\{"cert":.*\}/, "The certify_path should return JSON with a signed certificate"
  end

  private
  def fake_user(email)
    Warden.on_next_request do |proxy|
      u = mock()
      u.stubs(:email).returns(email).at_least_once
      proxy.set_user(u)
    end
  end

  def assert_json_response
    assert last_response.content_type == "application/json", "Content type was #{last_response.content_type} but must be application/json"
  end
end

