require 'omniauth-oauth'
require 'rexml/document'
require 'jwt'

module OmniAuth
  module Strategies
    class Mediawiki < OmniAuth::Strategies::OAuth
      option :name, 'mediawiki'

      def self.site
        if ENV['WIKI_AUTH_SITE']
          ENV['WIKI_AUTH_SITE']
        else
          'https://www.mediawiki.org'
        end
      end

      option :client_options,
             site: site,
             signup: false,
             authorize_path: '/w/index.php',
             authorize_path_title: 'Special:OAuth/authorize',
             access_token_path: '/w/index.php?title=Special:OAuth/token',
             request_token_path: '/w/index.php?title=Special:OAuth/initiate',
             oauth_callback: 'oob'

      def request_phase
        request_token = consumer.get_request_token(oauth_callback: callback_url)

        raise RequestTokenError unless valid_request_token?(request_token)

        session['oauth'] ||= {}
        session['oauth']['mediawiki'] = {
          'callback_confirmed' => request_token.callback_confirmed?,
          'request_token' => request_token.token,
          'request_secret' => request_token.secret }

        r = Rack::Response.new

        if request_token.callback_confirmed?
          r.redirect(authorize_url(request_token))
        else
          r.redirect(request_token.authorize_url(
                       oauth_callback: callback_url,
                       oauth_consumer_key: consumer.key
          ))
        end
        r.finish
      rescue RequestTokenError => e
        puts "There was a problem in getting the token from Mediawiki, here's what Mediawiki returned:"
        puts request_token.inspect
        raise e
      end

      class RequestTokenError < StandardError; end

      def callback_url
        'oob'
      end

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid { raw_info['sub'] }

      info do
        {
          name: raw_info['username'],
          urls: { 'server' => raw_info['iss'] }
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        @raw_info ||= parse_info(access_token.get('/w/index.php?title=Special:OAuth/identify'))

        @raw_info
      end

      private

      def authorize_url(request_token)
        params = authorize_url_parameters
        url = request_token.authorize_url(params)

        # All parameters that get passed through the returntoquery parameter
        # must be url-encoded, or they will be lost when mediawiki redirects.
        # The oauth_token query that gets appended to the url by omniauth
        # must thus be adjusted to pass through returntoquery.
        if params.include?(:returntoquery)
          url.gsub!('&oauth_token=', '%26oauth_token%3D')
        end
        url
      end

      def authorize_url_parameters
        params = { title: consumer.options[:authorize_path_title] }

        if consumer.options[:signup]
          params.merge!(
            title: 'Special:UserLogin',
            type: 'signup'
          )
        end

        # To preserve the oauth keys and redirect the user to authorization
        # after account creation, the oauth parameters must be put into
        # a returntoquery parameter, unless the user goes directly to
        # Special:OAuth/authorize
        if params[:title] == 'Special:OAuth/authorize'
          params.merge!(oauth_consumer_key: consumer.key)
        else
          params.merge!(
            returnto: 'Special:OAuth/authorize',
            returntoquery: "oauth_consumer_key=#{consumer.key}"
          )
        end
      end

      def valid_request_token?(request_token)
        request_token.token && request_token.secret
      end

      def parse_info(jwt_data)
        ident = jwt_data.body
        payload, _header = JWT.decode(ident, consumer.secret)

        payload
      rescue JWT::DecodeError
        fail!(:login_error)
        return { login_failed: true,
                 jwt_data: jwt_data.body }
      end
    end
  end
end
