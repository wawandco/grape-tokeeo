require "grape"
require "grape/tokeeo/version"

module Grape
  class API
    include Grape::Tokeeo

    class << self
      def ensure_token( options={} )
        Grape::Tokeeo.preshared(options, self) if options[:is].present?
      end
      def ensure_token_with(&block)
        Grape::Tokeeo.secure_with( self, &block)
      end
    end
  end

  module Tokeeo
    class << self
      def preshared(options, api_instance)
        api_instance.before do
          token = env['X-Api-Token']
          preshared_token = options[:is]

          error!('Token was not passed', 401) unless token.present?
          error!('Invalid token', 401) unless token == preshared_token
        end
      end

      def secure_with(api_instance, &block )
        api_instance.before do
          token = env['X-Api-Token']

          error!('Token was not passed', 401) unless token.present?
          error!('Invalid Token', 401) unless yield(token)
        end
      end
    end
  end
end
