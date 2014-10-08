require "grape"
require "grape/tokeeo/version"

module Grape
  class API
    include Grape::Tokeeo

    class << self
      def ensure_token( options={} )
        Grape::Tokeeo.build_preshared_token_security(options, self) if options[:is].present?
        Grape::Tokeeo.build_model_token_security(options, self) if options[:in].present?
      end

      def ensure_token_with(&block)
        Grape::Tokeeo.secure_with( self, &block)
      end
    end
  end

  module Tokeeo
    class << self
      def build_preshared_token_security(options, api_instance)
        api_instance.before do
          token = env['X-Api-Token']
          preshared_token = options[:is]

          error!('Token was not passed', 401) unless token.present?

          verification_passed = preshared_token.is_a?(Array) ?  preshared_token.include?(token) : token == preshared_token
          error!('Invalid token', 401) unless verification_passed
        end
      end

      def build_model_token_security(options, api_instance)
        clazz = options[:in]
        field = options[:field]

        raise Error("#{clazz} is not an ActiveRecord::Base subclass") unless clazz < ActiveRecord::Base

        api_instance.before do
          token = env['X-Api-Token']
          found = clazz.find_by("#{field.to_s}" => token )
          error!('Token was not passed', 401) unless token.present?
          error!('Invalid Token', 401) unless found.present?
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
