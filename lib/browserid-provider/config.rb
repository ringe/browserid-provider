module BrowserID
  #
  # authentication_path       Where to redirect users for login
  #                           defaults to: "/users/sign_in" (Devise default)
  #
  # provision_path            What HTTP path to deliver provisioning from
  #                           defaults to: "/browserid/provision"
  # certify_path              What HTTP path to deliver certifying from
  #                           defaults to: "/browserid/certify"
  # whoami_path               What HTTP path to serve user credentials at
  #                           defaults to: "/browserid/whoami"
  #
  # whoami                    Name of the middleware to get the current user object from (:user must respond to :email method)
  #                           This middleware will be called as follows: env['warden'].user.email
  #                           defaults to: "warden"
  #
  # private_key_path          Where is the BrowserID OpenSSL private key located
  #                           defaults to: "config/browserid_provider.pem"
  #
  # The "/.well-known/browserid" path is required from the BrowserID spec and used here.
  #
  # browserid_url             Which BrowserID server to use, ca be one of the following:
  #                           * dev.diresworb.org for development (default)
  #                           * diresworb.org     for beta
  #                           * browserid.org     for production
  #
  # server_name               The domain name we are providing BrowserID for (default to example.org)
  #
  # delegates                 Delegated domain names (see https://wiki.mozilla.org/Identity/BrowserID#BrowserID_Delegated_Support_Document)
  #                           defaults to: []
  #
  class Config < Hash
    # Creates an accessor that simply sets and reads a key in the hash:
    #
    #   class Config < Hash
    #     hash_accessor :login_path
    #   end
    #
    #   config = Config.new
    #   config.login_path = "/users/sign_in"
    #   config[:login_path] #=> "/users/sign_in"
    #
    #   config[:login_path] = "/login"
    #   config.login_path #=> "/login"
    #
    # Thanks to Warden. :)
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

    hash_accessor :login_path, :provision_path, :whoami, :whoami_path, :certify_path, :private_key_path, :browserid_url, :server_name, :delegates

    def initialize(other={})
      merge!(other)
      self[:login_path]       ||= "/users/sign_in"
      self[:provision_path]   ||= "/browserid/provision"
      self[:certify_path]     ||= "/browserid/certify"
      self[:whoami_path]      ||= "/browserid/whoami"
      self[:whoami]           ||= "warden"
      self[:private_key_path] ||= "config/browserid_provider.pem"
      self[:browserid_url]    ||= "dev.diresworb.org"
      self[:server_name]      ||= "example.org"
      self[:delegates]        ||= []
    end

    def get_issuer(dom)
      return dom if ( [ self[:server_name] ] + self[:delegates] ).include?(dom)
      return self[:server_name]
    end

    def urls
      [ self[:provision_path], self[:certify_path], self[:whoami_path], "/.well-known/browserid" ]
    end

  end
end
