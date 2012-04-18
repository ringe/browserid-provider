require "openssl"

module BrowserID
  class Identity
    attr_accessor :config

    # == Options ==
    # :key_path     where to store the OpenSSL private key
    def initialize(options = {})
      @config = BrowserID::Config.new(options)

      keypath = @config.private_key_path

      if File.exists?(keypath)
        File.open(keypath) {|f| @privkey = OpenSSL::PKey::RSA.new(f.read) }
        @pubkey = @privkey.public_key
      else
        require 'fileutils'
        FileUtils.mkdir_p keypath.sub(File.basename(keypath),'')
        @privkey = OpenSSL::PKey::RSA.new(2048)
        @pubkey = @privkey.public_key
        File.open(keypath, "w") {|f| f.write(@privkey) }
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
