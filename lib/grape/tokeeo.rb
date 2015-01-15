require "grape"
require "grape/tokeeo/version"

module Grape
  class API
    include Grape::Tokeeo

    class << self
      def ensure_token(options={})
        Grape::Tokeeo.build_preshared_token_security(options, self) if options[:is].present?
        Grape::Tokeeo.build_model_token_security(options, self) if options[:in].present?
      end

      def ensure_token_with(options={}, &block)
        Grape::Tokeeo.secure_with( self, options, &block)
      end

      def validate_token(options={} )
        warn "[DEPRECATED] 'validate_token' is deprecated, use 'ensure_token' instead"
        ensure_token(options)
      end

      def validate_token_with(options={}, &block)
        warn "[DEPRECATED] 'validate_token_with' is deprecated, use 'ensure_token_with' instead"
        ensure_token_with(options, &block)
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

      def message_for_missing_token( options= {})
        missing_message_to_use = options[:missing_message]
        missing_message_to_use ||= DEFAULT_MISSING_MESSAGE
      end

      def header_to_verify( options={} )
        header_to_use = options[:header]
        header_to_use ||= DEFAULT_HEADER
      end

      def header_for( key, request )
        token = request.headers[key]
        token ||= request.env[key]
      end

      def header_token( options, request )
        header_key = Grape::Tokeeo.header_to_verify(options)
        token = Grape::Tokeeo.header_for( header_key, request )
      end

      def verification_passed( options, token)
        preshared_token = options[:is]
        verification_passed = preshared_token.is_a?(Array) ?  preshared_token.include?(token) : token == preshared_token
      end

      def build_preshared_token_security(options, api_instance)
        api_instance.before do
          token = Grape::Tokeeo.header_token(options, request)
          error!(Grape::Tokeeo.message_for_missing_token(options), 401)  unless token.present?
          error!( Grape::Tokeeo.message_for_invalid_token(options) , 401) unless verification_passed(options, token)
        end
      end

      def use_supported_orm? (clazz)
        supported =   clazz < ActiveRecord::Base            if defined?(ActiveRecord::Base)
        supported ||= clazz < DataMapper::Resource          if defined?(DataMapper::Resource)
        supported ||= clazz < MongoMapper::Document         if defined?(MongoMapper::Document)
        supported ||= clazz < MongoMapper::EmbeddedDocument if defined?(MongoMapper::EmbeddedDocument)
        supported ||= clazz < Mongoid::Document             if defined?(Mongoid::Document)
        supported
      end

      def build_model_token_security(options, api_instance)
        clazz = options[:in]
        field = options[:field]

        raise Error("#{clazz} does not use any of the orm library supported") unless Grape::Tokeeo.use_supported_orm?(clazz)

        api_instance.before do
          token = Grape::Tokeeo.header_token(options, request)
          found = clazz.to_adapter.find_first("#{field.to_s}" => token)
          error!( Grape::Tokeeo.message_for_missing_token(options), 401) unless token.present?
          error!( Grape::Tokeeo.message_for_invalid_token(options), 401) unless found.present?
        end
      end

      def secure_with(api_instance, options, &block )
        api_instance.before do
          token = Grape::Tokeeo.header_token(options, request)
          error!( Grape::Tokeeo.message_for_missing_token(options), 401) unless token.present?
          error!( Grape::Tokeeo.message_for_invalid_token(options), 401) unless yield(token)
        end
      end
    end
  end
end
