require 'erb'
module BrowserID
  class Template
    PATH = File.expand_path(File.join(File.dirname(__FILE__), "../..", "app", "assets", "browserid"))

    def self.render(template)
      template = ERB.new File.read(PATH + "/404.html.erb")
      [template.result]
    end

    def self.css_styles
      File.read(PATH + "/bootstrap.css")
    end
  end
end
