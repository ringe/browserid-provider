require 'erb'
module BrowserID
  # Simple class to render ERB templates.
  class Template
    PATH = File.expand_path(File.join(File.dirname(__FILE__), "../..", "app", "assets", "browserid"))

    def initialize(template_vars)
      @vars = template_vars
    end

    def get_binding
      binding
    end

    def self.render(template, template_vars)
      rhtml = ERB.new File.read(PATH + "/" + template + ".html.erb")
      view = BrowserID::Template.new(template_vars)
      [rhtml.result(view.get_binding)]
    end

    def self.css_styles
      File.read(PATH + "/bootstrap.css")
    end
  end
end
