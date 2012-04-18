require "browserid-provider/version"
require "browserid-provider/provider"
require "browserid-provider/identity"

module BrowserID
  #
  # authentication_path       Where to redirect users for login
  #                           defaults to: /users/sign_in
  #
  # provision_path            What path to deliver provisioning from
  #                           defaults to: /browserid/provision
  # certify_path              What path to deliver certifying from
  #                           defaults to: /browserid/certify
  # whoami_path               What path to serve user credentials at
  #                           defaults to: /whoami
  #
  # whoami                    What function to call for user info
  #                           defaults to: env['warden'].user
  #
  # private_key_path          Where is the BrowserID OpenSSL private key located
  #                           defaults to: config/browserid_provider.pem
  class Config < Hash
    hash_accessor :login_path, :provision_path, :whoami, :whoami_path, :certify_path, :private_key_path
  end
end
