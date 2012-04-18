require "openssl"

module BrowserID
  class Identity
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

    # Return BrowserID Identity JSON
    def to_json
      {
        "public-key" => { "algorithm"=> "RS", "n" => public_key.n.to_s, "e" => public_key.e.to_s },
        "authentication" => authentication_path,
        "provisioning" => provision_path
      }.to_json
    end

    def authentication_path
      "/users/sign_in"
    end

    def provision_path
      "/provision"
    end
  end
end
