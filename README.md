# OmniAuth OpenStreetMap

This gem contains the OpenStreetMap strategy for OmniAuth.

OpenStreetMap uses the OAuth 1.0a flow, you can read about it here: http://wiki.openstreetmap.org/wiki/OAuth

## How To Use It

Usage is as per any other OmniAuth 1.0 strategy. So let's say you're using Rails, you need to add the strategy to your `Gemfile` along side omniauth:

    gem 'omniauth'
    gem 'omniauth-osm'

Of course if one or both of these are unreleased, you may have to pull them in directly from github e.g.:

    gem 'omniauth', :git => 'https://github.com/intridea/omniauth.git'
    gem 'omniauth-osm', :git => 'https://github.com/sozialhelden/omniauth-osm.git'

Once these are in, you need to add the following to your `config/initializers/omniauth.rb`:

    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :osm, "consumer_key", "consumer_secret"
    end

You will obviously have to put in your key and secret, which you get when you register your app with OpenStreetMap.

Now just follow the README at: https://github.com/intridea/omniauth

## Note on Patches/Pull Requests

- Fork the project.
- Make your feature addition or bug fix.
- Add tests for it. This is important so I don’t break it in a future version unintentionally.
- Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
- Send me a pull request. Bonus points for topic branches.
