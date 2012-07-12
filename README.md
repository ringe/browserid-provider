# A Rack BrowserID Provider

Become a Mozilla BrowserID Primary Identity Provider.

This is a Rack middleware for providing the BrowserID Primary Identity
service. I have so far tested this only with Ruby on Rails.

## Installation

Add this line to your application's Gemfile:

    gem 'browserid-provider'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install browserid-provider

## Usage

In you Rails app config/application.rb, add:

```ruby
  config.middleware.use BrowserID::Provider, :server_name => "example.org", :delegates => ["example.com"]
```

The default setup relies on Warden to see which user is logged in. This
can easily be customized to fit any middleware function.

The available configuration options are the following:

*   authentication_path
    Where to redirect users for login
    defaults to: "/users/sign_in" (Devise default)
*   provision_path
    What HTTP path to deliver provisioning from
    defaults to: "/browserid/provision"
*   certify_path
    What HTTP path to deliver certifying from
    defaults to: "/browserid/certify"
*   whoami_path
    What HTTP path to serve user credentials at
    defaults to: "/browserid/whoami"
*   jquery_path
    What HTTP path JQuery is served at
    defaults to: "/assets/jquery.js"
*   whoami
    Name of the middleware to get the current user object from (:user must respond to :email method)
    This middleware will be called as follows: env['warden'].user.email
    defaults to: "warden"
*   private_key_path
    Where is the BrowserID OpenSSL private key located
    defaults to: "config/browserid_provider.pem"
*   The "/.well-known/browserid" path is required from the BrowserID spec and used here.
*   browserid_url
    Which BrowserID server to use, ca be one of the following:
    *   login.dev.anosrep.org for development (default)
    *   login.anosrep.org     for beta
    *   login.persona.org     for production
*   server_name
    The domain name we are providing BrowserID for (default to example.org)
*   delegates
    An array of strings representing [authority delegates] [1]

[1]: https://wiki.mozilla.org/Identity/BrowserID#BrowserID_Delegated_Support_Document "Mozilla Identity Wiki"

The client side is JavaScript enabled. For Rails use:

```erb
    <%= browserid_authentication_tag %>
    <!-- Enable BrowserID authentication API on the form #new_user -->
    <%= enable_browserid_javascript_tag "new_user" %>
```

In your login form, add a cancel button like this:

```erb
  <%= button_to_function "Cancel", "navigator.id.cancelAuthentication()" %>
```

Without Rails view helpers (in any framework), you can do:

```javascript
  $('form#new_user').bind('ajax:success', function(data, status, xhr) { navigator.id.completeAuthentication() })
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
