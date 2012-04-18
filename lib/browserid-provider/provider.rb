module BrowserID
  module Provider

    # The BrowserID Provider Rack App
    class App
      def initialize(app, options = {})
        @app = app
        @urls = options[:urls]
        @root = options[:root]
      end

      # Rack enabled!
      def call(env)
        return @app.call(env) unless @urls.include? env["PATH_INFO"]
        "Hellow from BrowserID"
      end

    end
  end
end
