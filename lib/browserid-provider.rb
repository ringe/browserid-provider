require "browserid-provider/version"
require "browserid-provider/config"
require "browserid-provider/identity"
require "browserid-provider/provider"
require "browserid-provider/template"

if defined?(Rails)
  require "browserid-provider/engine"
  require "browserid-provider/railtie"
end
