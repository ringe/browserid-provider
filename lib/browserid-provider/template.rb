require 'erb'
module BrowserID
  class Template
    PATH = File.expand_path(File.join(File.dirname(__FILE__), "../..", "app", "assets", "browserid"))

    def initialize(env)
      @env = env
    end

    def get_binding
      binding
    end

    def self.render(template, env)
      rhtml = ERB.new File.read(PATH + "/" + template + ".html.erb")
      view = BrowserID::Template.new(env)
      [rhtml.result(view.get_binding)]
    end

    def self.css_styles
      File.read(PATH + "/bootstrap.css")
    end
  end
end
