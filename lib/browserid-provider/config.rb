module BrowserID
  #
  # authentication_path       Where to redirect users for login
  #                           defaults to: "/users/sign_in" (Devise default)
  #
  # provision_path            What path to deliver provisioning from
  #                           defaults to: "/browserid/provision"
  # certify_path              What path to deliver certifying from
  #                           defaults to: "/browserid/certify"
  # whoami_path               What path to serve user credentials at
  #                           defaults to: "/whoami"
  #
  # whoami                    What function to call for user info
  #                           defaults to: "env['warden'].user"
  #
  # private_key_path          Where is the BrowserID OpenSSL private key located
  #                           defaults to: "config/browserid_provider.pem"
  #
  # The "/.well-known/browserid" path is required from the BrowserID spec and used here.
  class Config < Hash
    # Creates an accessor that simply sets and reads a key in the hash:
    #
    #   class Config < Hash
    #     hash_accessor :failure_app
    #   end
    #
    #   config = Config.new
    #   config.failure_app = Foo
    #   config[:failure_app] #=> Foo
    #
    #   config[:failure_app] = Bar
    #   config.failure_app #=> Bar
    #
    def self.hash_accessor(*names) #:nodoc:
      names.each do |name|
        class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{name}
            self[:#{name}]
          end

          def #{name}=(value)
            self[:#{name}] = value
          end
        METHOD
      end
    end

    hash_accessor :login_path, :provision_path, :whoami, :whoami_path, :certify_path, :private_key_path

    def initialize(other={})
      merge!(other)
      self[:login_path]       ||= "/users/sign_in"
      self[:provision_path]   ||= "/browserid/provision"
      self[:certify_path]     ||= "/browserid/certify"
      self[:whoami_path]      ||= "/whoami"
      self[:whoami]           ||= "env['warden'].user"
      self[:private_key_path] ||= "config/browserid_provider.gem"
    end

    def urls
      [ self[:login_path], self[:provision_path], self[:certify_path], self[:whoami_path], self[:whoami], self[:private_key_path], "/.well-known/browserid" ]
    end

  end
end

