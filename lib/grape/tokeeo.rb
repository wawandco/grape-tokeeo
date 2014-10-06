require "grape"
require "grape/tokeeo/version"

module Grape
  class API
    include Grape::Tokeeo

    class << self
      def ensure_token( options={} )
        Grape::Tokeeo.preshared(options, self) if options[:is].present?
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
    end
  end
end
