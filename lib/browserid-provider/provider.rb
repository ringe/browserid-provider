module BrowserID
  # The BrowserID Provider Rack App
  #
  # Default paths are:
  #   GET  /users/sign_in
  #   GET  /browserid/provision
  #   GET  /browserid/whoami
  #   POST /browserid/certify
  class Provider
    attr_accessor :config, :env, :req, :identity

    def initialize(app = nil, options = {})
      @app, @config = app, BrowserID::Config.new(options)
      @identity = BrowserID::Identity.new
    end

    # Rack enabled!
    def call(env)
      @env, @path = env, env["PATH_INFO"], @req = Rack::Request.new(env)
      env['browserid'] = @config

      # Return Not found or send call back to middleware stack unless the URL is captured here
      return (@app ? @app.call(env) : not_found) unless @config.urls.include? @path

      case @path
        when "/.well-known/browserid"
          @req.get? ? well_known_browserid : not_found
        when config.whoami_path
          @req.get? ? whoami : not_found
        when config.provision_path
          @req.get? ? provision : not_found
        when config.certify_path
          @req.post? ? certify : not_found
        else not_found
      end
    end

    private
    def well_known_browserid
      [ 200, {"Content-Type" => "application/json"}, [@identity.to_json] ]
    end

    def whoami
      email = current_user_email
      [ 200, {"Content-Type" => "application/json"}, [{ user: email ? email.sub(/@.*/,'') : nil }.to_json] ]
    end

    #
    # The certify function will be called by BrowserID with a public key and duration as parameters. The
    # request is a POST with JSON data that looks like this:
    #
    #   {
    #     "pubkey" :
    #       {
    #         "algorithm":"DS",
    #         "y":"62b0ea6936a7ab30c95d8ffbbc77438a342faed99b6fc643a58f28d9ed2017177354f9f1d1d7e6b9e1c543780c3517953a124e66bc409fcaaa671d87a39cf897b32f47aaaffb7a3d297b89f9e116870a2182e2b2f84d68a7bc21a3f7934727e45e50a083e71a965d0cc320062598e407463f0c31cc2c20ed74d9bda98b21c902",
    #         "p":"ff600483db6abfc5b45eab78594b3533d550d9f1bf2a992a7a8daa6dc34f8045ad4e6e0c429d334eeeaaefd7e23d4810be00e4cc1492cba325ba81ff2d5a5b305a8d17eb3bf4a06a349d392e00d329744a5179380344e82a18c47933438f891e22aeef812d69c8f75e326cb70ea000c3f776dfdbd604638c2ef717fc26d02e17",
    #         "q":"e21e04f911d1ed7991008ecaab3bf775984309c3",
    #         "g":"c52a4a0ff3b7e61fdf1867ce84138369a6154f4afa92966e3c827e25cfa6cf508b90e5de419e1337e07a2e9e2a3cd5dea704d175f8ebf6af397d69e110b96afb17c7a03259329e4829b0d03bbc7896b15b4ade53e130858cc34d96269aa89041f409136c7242a38895c9d5bccad4f389af1d7a4bd1398bd072dffa896233397a"
    #       },
    #     "duration":3600
    #   }
    #
    # We're going to certify that public key for the currently logged in user.
    #
    def certify
      email = current_user_email
      return err "No user is logged in." unless email

      # Get params from Rails' ActionDispatch or from Rack Request
      params = env["action_dispatch.request.request_parameters"] ? env["action_dispatch.request.request_parameters"] : @req.params
      return err "Missing a required parameter (duration, pubkey)" if params.keys.sort != ["duration", "pubkey"]

      expiration = (Time.now.strftime("%s").to_i + params["duration"].to_i) * 1000

      # Old certificate structure, changed to fit with https://github.com/mozilla/browserid-certifier/blob/master/bin/certifier#L51
#      issue = {
#        "principal" => { "email"=> email }
#        "hostname" => issuer(email),
#        "exp" => expiration,
#        "public-key" => params["pubkey"],
#      }
      issue = {
        "email"=> email,
        "pubkey" => params["pubkey"],
        "duration" => expiration,
        "hostname" => issuer(email)
      }

      jwt = JSON::JWT.new(issue)
      jws = jwt.sign(@identity.private_key, :RS256)

      return [ 200, {"Content-Type" => "application/json"}, [{"success" => true, "cert" => jws.to_s }.to_json] ]
    end

    # Something went wrong.
    def err(message)
      [ 403, {"Content-Type" => "text/plain"}, [message] ]
    end

    # Return the provision iframe content.
    def provision
      email = current_user_email
      template_vars = @config.merge( { :domain_name => issuer(email) } )
      [200, {"Content-Type" => "text/html"}, BrowserID::Template.render("provision", template_vars)]
    end

    # This middleware doesn't find what you are looking for.
    def not_found
      [404, {"Content-Type" => "text/html"}, BrowserID::Template.render("404", nil)]
    end

    # Return the issuing domain name
    def issuer(email)
      @config.get_issuer(email ? email.sub(/.*@/,'') : nil)
    end

    # Return the email of the user logged in currently, or nil
    def current_user_email
      begin
        current_user = @env[config.whoami].user
        current_user ? current_user.email : nil
      rescue NoMethodError
        raise NoMethodError, "The middleware provided in BrowserID::Config.whoami doesn't have a :user method, or the :user doesn't have the :email method."
      end
    end
  end
end
