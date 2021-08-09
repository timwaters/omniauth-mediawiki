# OmniAuth Mediawiki


This gem contains the MediaWiki strategy for OmniAuth.

MediaWiki uses the OAuth 1.0a extension, you can read about it here: https://www.mediawiki.org/wiki/Extension:OAuth

## How To Use It

Usage is as per any other OmniAuth 1.0 strategy. So let's say you're using Rails, you need to add the strategy to your `Gemfile` alongside omniauth:

```ruby
gem 'omniauth'
gem 'omniauth-mediawiki'
```

Of course if one or both of these are unreleased, you may have to pull them in directly from github e.g.:

```ruby
gem 'omniauth', :git => 'https://github.com/intridea/omniauth.git'
gem 'omniauth-mediawiki', :git => 'https://github.com/timwaters/omniauth-mediawiki.git'
```

Once these are in, you need to add the following to your `config/initializers/omniauth.rb` (with your key and secret, which you get when you register your app on your particular wiki):

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :mediawiki, CONSUMER_KEY, CONSUMER_SECRET
end
```

If you are using devise, this is how it looks like in your `config/initializers/devise.rb`:

```ruby
config.omniauth :mediawiki, CONSUMER_KEY, CONSUMER_SECRET,
                client_options: {:site => 'https://commons.wikimedia.org' }
```

You can also use the `signup` option to configure it to direct users to the MediaWiki account creation page. Use `signup_params` to optionally add parameters to the account creation URL.

```ruby
config.omniauth :mediawiki_signup, CONSUMER_KEY, CONSUMER_SECRET,
                name: 'mediawiki_signup',
                strategy_class: OmniAuth::Strategies::Mediawiki,
                client_options: {
                  site: 'https://en.wikipedia.org',
                  signup: true,
                  signup_params: { geEnabled: 1, geForceVariant: 'control' }
                }
```

Now just follow the README at: https://github.com/intridea/omniauth

## Info about the MediaWiki OAuth extension

In general see the pages around https://www.mediawiki.org/wiki/OAuth/For_Developers for more information

When registering for a new OAuth consumer registration you need to specify the callback url properly. e.g. for development:

    http://localhost:3000/u/auth/mediawiki/callback
    http://localhost:3000/users/auth/mediawiki/callback

Internally the strategy has to use `/w/index.php?title=` paths like so:

```ruby
:authorize_path => '/w/index.php',
:authorize_path_params => { :title => 'Special:OAuth/authorize' },
:access_token_path => '/w/index.php?title=Special:OAuth/token',
:request_token_path => '/w/index.php?title=Special:OAuth/initiate',
```

The initial path to the wiki can be modified by passing in alternative values for `:authorize_path_params`, in which case, 'Special:OAuth/authorize' will be passed as
the `returnto` parameter, and the oauth keys will be passed into a `returntoquery` parameter.

Note also that new proposed registrations on mediawiki.org will work with your mediawki user that you registered the application with but have to be approved by an admin user for them to be usable by other users.

## Specifying Target Wiki

If you would like to use this plugin against a wiki you can use the environment variable WIKI_AUTH_SITE to set the server to connect to. Alternatively you can pass the site as a client_option to the omniauth config:

```ruby
config.omniauth :mediawiki, "consumer_key", "consumer_secret",  
                :client_options => {:site => 'https://commons.wikimedia.org' }
```

If no site is specified the www.mediawiki.org wiki will be used.

## How to call the MediaWiki API via Omniauth

Within a Devise / Omniauth setup, in the callback method, you can directly get an OAuth::AccessToken  via ```request.env["omniauth.auth"]["extra"]["access_token"]``` or you can get the token and secret from ```request.env["omniauth.auth"]["credentials"]["token"]``` and ```request.env["omniauth.auth"]["credentials"]["secret"]```

Assuming these are stored in the user model, the following could be used to query the mediawiki API at a later date. In this example we are using the Wikimedia Commons API https://www.mediawiki.org/wiki/API:Main_page

```ruby
@consumer = OAuth::Consumer.new "consumer_key",  "consumer_secret",  
                                {:site=>"https://commons.wikimedia.org"}
@access_token = OAuth::AccessToken.new(@consumer, user.auth_token, user.auth_secret)
uri = 'https://commons.wikimedia.org/w/api.php?action=query&meta=userinfo&uiprop=rights|editcount&format=json'
resp = @access_token.get(URI.encode(uri))
logger.debug resp.body.inspect
# {"query":{"userinfo":{"id":12345,"name":"WikiUser",
# "rights":["read","writeapi","purge","autoconfirmed","editsemiprotected","skipcaptcha"],
# "editcount":2323}}}
```

## Integration testing

If you want to use the OAuth authorization flow in integration tests, you need to short-circuit the callback step of the process, like this:

```ruby
OmniAuth.config.test_mode = true
allow_any_instance_of(OmniAuth::Strategies::Mediawiki)
  .to receive(:callback_url).and_return('/users/auth/mediawiki/callback')
OmniAuth.config.mock_auth[:mediawiki] = OmniAuth::AuthHash.new(
  provider: 'mediawiki',
  uid: '12345',
  info: { name: 'TestUser' },
  credentials: { token: 'foo', secret: 'bar' }
)
```
