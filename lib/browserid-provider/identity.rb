require "openssl"

module BrowserID
  class Identity
    attr_accessor :pubkey, :privkey, :browserid_url

    # == Options ==
    # :key_path     where to store the OpenSSL private key
    def initialize(options = {})
      options[:key_path] ||= "config/browserid_provider.pem"

      if File.exists?(options[:key_path])
        File.open(options[:key_path]) {|f| @privkey = OpenSSL::PKey::RSA.new(f.read) }
        @pubkey = @privkey.public_key
      else
        @privkey = OpenSSL::PKey::RSA.new(2048)
        @pubkey = @privkey.public_key
        File.open(key_path, "w") {|f| f.write(@privkey) }
      end
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
  end
end
