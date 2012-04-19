module BrowserID
  # The BrowserID Provider Rack App
#match ".well-known/:action" => 'verified_emails'
#get "provision(/:email(/:duration))" => 'verified_emails#provision'
#get "whoami" => 'verified_emails#whoami'
#post "certify" => 'verified_emails#certify'
  # Default paths are:
  #  GET  /.well-known/browserid
  #  GET  /whoami
  #  GET  /provision
  #  POST /certify
  class Provider
    attr_accessor :config, :env, :req

    def initialize(app = nil, options = {})
      @app, @config = app, BrowserID::Config.new(options)
    end

    # Rack enabled!
    def call(env)
      @env, @path = env, env["PATH_INFO"], @req = Rack::Request.new(env)

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
      [ 200, {"Content-Type" => "application/json"}, [BrowserID::Identity.new.to_json] ]
    end

    def whoami
      email = current_user_email
      [ 200, {"Content-Type" => "application/json"}, [{ user: email ? email.sub(/@.*/,'') : nil }.to_json] ]
    end

    def certify
      email = current_user_email
      return err "No user is logged in." unless email
      return err "Missing a required parameter (duration, pubkey)" if @req.params.keys.sort != ["duration", "pubkey"]

      bi = BrowserID::Identity.new
      expiration = (Time.now.strftime("%s").to_i + @req.params["duration"].to_i) * 1000
      issue = { "iss" => @config.server_name,
        "exp" => expiration,
        "public-key" => @req.params["pubkey"],
        "principal" => { "email"=> email }
      }
      jwt = JSON::JWT.new(issue)
      jws = jwt.sign(bi.private_key, :RS256)

      return [ 200, {"Content-Type" => "application/json"}, [{ "cert" => jws.to_s }.to_json] ]
    end

    def err(message)
      [ 403, {"Content-Type" => "text/plain"}, [message] ]
    end

    def provision
      [200, {"Content-Type" => "text/html"}, BrowserID::Template.render("provision", @config)]
    end

    def not_found
      [404, {"Content-Type" => "text/html"}, BrowserID::Template.render("404", @env)]
    end

    def current_user_email
      begin
        current_user = eval config.whoami
        current_user ? current_user.email : nil
      rescue NoMethodError
        raise NoMethodError, "The function provided in BrowserID::Config.whoami doesn't exist."
      end
    end
  end
end
