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
      raw <<EOF
        <script type='text/javascript'>
          (function() {
            function fail() {
              var msg = 'user is not authenticated as target user';
              navigator.id.raiseAuthenticationFailure(msg);
            };

            $('form##{id}').bind('ajax:success', function(data, status, xhr) { navigator.id.completeAuthentication() })
            $('form##{id}').bind('ajax:error', function(data, status, xhr) { fail(); })

            navigator.id.beginAuthentication(function(email) {
              $('form##{id} #user_email').val(email);
            });
          }());
        </script>
EOF
    end

    # The URL to the BrowserID official JavaScript
    def browserid_authentication_api_js_url
      "https://#{ request.env['browserid'][:browserid_url] }/authentication_api.js"
    end

  end
end
