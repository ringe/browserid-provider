module BrowserId
  module ViewHelpers

    # BrowserID JavaScript tags:
    # - The official BrowserID include.js
    # - The Devise enabled login and assertion reponse
    def browserid_authentication_tag
      javascript_include_tag(browserid_authentication_api_js_url)
    end

    # JavaScript enable BrowserID authentication for the form with the given #id
    def enable_browserid_javascript_tag(id)
      "<script type='text/javascript'>$('form##{id}').bind('ajax:success', function(data, status, xhr) { navigator.id.completeAuthentication() })</script>"
    end

    # The URL to the BrowserID official JavaScript
    def browserid_authentication_api_js_url
      "https://#{ debugger }/authentication_api.js"
    end

  end
end
