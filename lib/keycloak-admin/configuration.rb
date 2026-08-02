# frozen_string_literal: true
require "base64"

module KeycloakAdmin
  class Configuration
    attr_accessor :server_url, :server_domain, :client_id, :client_secret, :client_realm_name, :use_service_account, :username, :password, :logger, :faraday_options, :faraday_adapter

    # Treat a cached token as expired this many seconds before its real expiry, so it
    # cannot go stale between the check below and the request that relies on it.
    TOKEN_EXPIRY_SAFETY_MARGIN_SECONDS = 10

    FILTERED_ATTRIBUTES  = %i[@client_secret @password @cached_token].freeze
    FILTERED_PLACEHOLDER = "[FILTERED]".freeze

    def initialize
      @token_mutex = Mutex.new
    end

    def inspect
      rendered = instance_variables.map do |name|
        value = instance_variable_get(name)
        shown  = if FILTERED_ATTRIBUTES.include?(name) && !value.nil?
          FILTERED_PLACEHOLDER
        else
          value.inspect
        end
        "#{name}=#{shown}"
      end
      "#<#{self.class.name} #{rendered.join(", ")}>"
    end

    # Returns the cached token, fetching one through the block if there is none.
    # The block runs at most once across threads.
    def fetch_token_once
      token = cached_token
      if token.nil?
        @token_mutex.synchronize do
          token = cached_token
          token.nil? ? cache_token(yield) : token
        end
      else
        token
      end
    end

    # Returns the cached TokenRepresentation, or nil if there is none or it is (about to be) expired.
    def cached_token
      return nil if @token_expires_at.nil? || Time.now >= @token_expires_at
      @cached_token
    end

    def cache_token(token_representation)
      return token_representation unless token_representation.expires_in.is_a?(Numeric)
      @cached_token     = token_representation
      @token_expires_at = Time.now + token_representation.expires_in - TOKEN_EXPIRY_SAFETY_MARGIN_SECONDS
      token_representation
    end

    def clear_cached_token!
      @token_expires_at = nil
      @cached_token     = nil
    end

    def body_for_token_retrieval
      if use_service_account
        body_for_service_account
      else
        body_for_username_and_password
      end
    end

    def headers_for_token_retrieval
      if use_service_account
        headers_for_service_account
      else
        headers_for_username_and_password
      end
    end

    private

    def body_for_service_account
      {
        grant_type:    "client_credentials"
      }
    end

    def body_for_username_and_password
      {
        username:      username,
        password:      password,
        grant_type:    "password",
        client_id:     client_id,
        client_secret: client_secret
      }
    end

    def headers_for_service_account
      id_and_secret = Base64::strict_encode64("#{client_id}:#{client_secret}")
      {
        Authorization: "Basic #{id_and_secret}"
      }
    end

    def headers_for_username_and_password
      {}
    end
  end
end
