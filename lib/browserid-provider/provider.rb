module BrowserID
  module Provider

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
    class App
      def initialize(app, options = {})
        @urls = ["/.well-known/browserid", "/whoami", "/provision", "/certify"]

        @app = app
#        @urls = options[:urls]
#        @root = options[:root]
      end

      # Rack enabled!
      def call(env)
        return @app.call(env) unless @urls.include? env["PATH_INFO"]
        "Hellow from BrowserID"
      end

    end
  end
end
