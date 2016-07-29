require 'omniauth-oauth'
require 'rexml/document'
require 'jwt'

module OmniAuth
  module Strategies
    class Mediawiki < OmniAuth::Strategies::OAuth
      option :name, "mediawiki"

      def self.site
        if ENV['WIKI_AUTH_SITE']
          ENV['WIKI_AUTH_SITE']
        else
          "https://www.mediawiki.org"
        end
      end


      option :client_options, {
        :site => site,
        :authorize_path => '/wiki/Special:Oauth/authorize',
        :access_token_path => '/w/index.php?title=Special:OAuth/token',
        :request_token_path => '/w/index.php?title=Special:OAuth/initiate',
        :oauth_callback=> "oob"
      }

      def request_phase
        request_token = consumer.get_request_token(:oauth_callback => callback_url)
        session['oauth'] ||= {}
        session['oauth'][name.to_s] = {'callback_confirmed' => request_token.callback_confirmed?, 'request_token' => request_token.token, 'request_secret' => request_token.secret}
        r = Rack::Response.new

        if request_token.callback_confirmed?
          r.redirect(request_token.authorize_url(
                       :oauth_consumer_key => consumer.key
          ))
        else
          r.redirect(request_token.authorize_url(
                       :oauth_callback => callback_url,
                       :oauth_consumer_key => consumer.key
          ))
        end

        r.finish
      end

      def callback_url
        'oob'
      end

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid{ raw_info["sub"] }

      info do
        {
          :name => raw_info["username"],
          :urls => {"server" => raw_info["iss"]}
        }
      end

      extra do
        {
          'raw_info' => {}
        }
      end


      def raw_info
        @raw_info ||= parse_info(access_token.get('/w/index.php?title=Special:OAuth/identify'))

        @raw_info
      end
      
      private
      
      def parse_info(jwt_data)
        ident = jwt_data.body
        payload, header = JWT.decode(ident, consumer.secret)
        
        payload
      end

    end
  end
end
