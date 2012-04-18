require "openssl"
module BrowserID
  class Provider
    attr_accessor :pubkey, :privkey, :browserid_url

    def initialize(app, options = {})
      @app = app
      @urls = options[:urls]
      @root = options[:root]

      key_path = "config/browserid_provider.pem"

      if File.exists?(key_path)
        File.open(key_path) {|f| @privkey = OpenSSL::PKey::RSA.new(f.read) }
        @pubkey = @privkey.public_key
      else
        @privkey = OpenSSL::PKey::RSA.new(2048)
        @pubkey = @privkey.public_key
        File.open(key_path, "w") {|f| f.write(@privkey) }
      end
    end

    # Rack enabled!
    def call(env)
      return @app.call(env) unless @urls.include? env["PATH_INFO"]
      "Hellow from BrowserID"
    end

    def public_key
      @pubkey
    end

    def private_key
      @privkey
    end

    def to_json
      {
        "public-key" => { "algorithm"=> "RS", "n" => @pubkey.n.to_s, "e" => @pubkey.e.to_s },
        "authentication" => "/sign_in",
        "provisioning" => "/provision"
      }.to_json
    end

    def browserid_url

    end
  end
end
