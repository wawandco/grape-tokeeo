require "grape"
require "grape/tokeeo/version"

module Grape
  class API
    include Grape::Tokeeo

    class << self
      def validate_token( options={} )
        Grape::Tokeeo.build_preshared_token_security(options, self) if options[:is].present?
        Grape::Tokeeo.build_model_token_security(options, self) if options[:in].present?
      end

      def validate_token_with(options={}, &block)
        Grape::Tokeeo.secure_with( self, options, &block)
      end
    end
  end

  module Tokeeo
    DEFAULT_INVALID_MESSAGE = 'Invalid Token'
    DEFAULT_MISSING_MESSAGE = 'Token was not passed'
    DEFAULT_HEADER = 'X-Api-Token'

    class << self

      def message_for_invalid_token( options={} )
        invalid_message_to_use = options[:invalid_message]
        invalid_message_to_use ||= DEFAULT_INVALID_MESSAGE
      end

      def header_to_verify( options={} )
        header_to_use = options[:header]
        header_to_use ||= DEFAULT_HEADER
      end

      def build_preshared_token_security(options, api_instance)
        api_instance.before do
          header = Grape::Tokeeo.header_to_verify(options)
          token = request.headers[header]
          token ||= request.env[header]
          
          preshared_token = options[:is]

          error!(DEFAULT_MISSING_MESSAGE, 401) unless token.present?

          verification_passed = preshared_token.is_a?(Array) ?  preshared_token.include?(token) : token == preshared_token
          error!( Grape::Tokeeo.message_for_invalid_token(options) , 401) unless verification_passed
        end
      end

      def build_model_token_security(options, api_instance)
        clazz = options[:in]
        field = options[:field]

        raise Error("#{clazz} is not an ActiveRecord::Base subclass") unless clazz < ActiveRecord::Base

        api_instance.before do
          header = Grape::Tokeeo.header_to_verify(options)
          token = env[header]
          found = clazz.find_by("#{field.to_s}" => token )

          error!(DEFAULT_MISSING_MESSAGE, 401) unless token.present?
          error!( Grape::Tokeeo.message_for_invalid_token(options), 401) unless found.present?
        end
      end

      def secure_with(api_instance, options, &block )
        api_instance.before do
          header = Grape::Tokeeo.header_to_verify(options)
          token = env[header]

          error!( DEFAULT_MISSING_MESSAGE, 401) unless token.present?
          error!( Grape::Tokeeo.message_for_invalid_token(options), 401) unless yield(token)
        end
      end
    end
  end
end
