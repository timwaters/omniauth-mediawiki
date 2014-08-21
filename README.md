# OmniAuth Mediawiki


This gem contains the MediaWiki strategy for OmniAuth.

MediaWiki uses the OAuth 1.0a extension, you can read about it here: https://www.mediawiki.org/wiki/Extension:OAuth

## How To Use It

Usage is as per any other OmniAuth 1.0 strategy. So let's say you're using Rails, you need to add the strategy to your `Gemfile` along side omniauth:

    gem 'omniauth'
    gem 'omniauth-mediawiki'

Of course if one or both of these are unreleased, you may have to pull them in directly from github e.g.:

    gem 'omniauth', :git => 'https://github.com/intridea/omniauth.git'
    gem 'omniauth-mediawiki', :git => 'https://github.com/timwaters/omniauth-mediawiki.git'

Once these are in, you need to add the following to your `config/initializers/omniauth.rb`:

    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :mediawiki, "consumer_key", "consumer_secret"
    end

If you are using devise, this is how it looks like in your `config/initializers/devise.rb`:

    config.omniauth :mediawiki, "consumer_key", "consumer_secret", :client_options => {:site => 'http://commons.wikimedia.org' }

You will obviously have to put in your key and secret, which you get when you register your app on your particula Wiki.

Now just follow the README at: https://github.com/intridea/omniauth

## Specifying Target Wiki

If you would like to use this plugin against a wiki you should pass this you can use the environment variable WIKI_AUTH_SITE to set the server to connect to. Alternatively you can pass the site as a client_option to the omniauth config:

    config.omniauth :mediawiki, "consumer_key", "consumer_secret",  :client_options => {:site => 'http://commons.wikimedia.org' }

if no site is specified the www.mediawiki.org wiki will be used.
