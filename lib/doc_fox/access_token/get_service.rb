# frozen_string_literal: true

class DocFox::AccessToken::GetService < DocFox::BaseService
  attr_reader :authentication_service

  validate on: :request do
    errors.merge!(authentication_service.errors) unless authentication_service.success?
  end

  skip_callback :call, :before, :set_access_token

  before_call :authenticate

  after_call :set_facade

  delegate_missing_to :@facade

  # Get access token.
  #
  # ==== Examples
  #
  #   service = DocFox::AccessToken::GetService.call
  #   service.token # => '1000.xxxx.yyyy'
  #   service.expires_at # => '2025-01-01T06:00:00.000+02:00'
  #
  # GET /api/v2/tokens/new
  def call
    connection.get('tokens/new')
  end

  private

  def connection
    @_connection ||= Faraday.new do |conn|
      conn.url_prefix = base_url
      conn.headers['X-Client-Api-Key'] = api_key
      conn.headers['X-Client-Signature'] = signature
      conn.request :json
      conn.request :retry
      conn.response :json
      conn.response :logger, logger, **logger_options do |logger|
        logger.filter(/(X-Client-Api-Key:).*"(.+)."/i, '\1 [FILTERED]')
        logger.filter(/(X-Client-Signature:).*"(.+)."/i, '\1 [FILTERED]')
        logger.filter(/"token":"([^"]+)"/i, '"token":"[FILTERED]"')
      end
      conn.adapter Faraday.default_adapter
    end
  end

  def authenticate
    @authentication_service = DocFox::Authentication::GetService.call
  end

  def signature
    # Turns 'HMAC-SHA256' -> 'SHA256'.
    digest_algorithm = authentication_service.digest_algorithm.split('-').last

    OpenSSL::HMAC.hexdigest(digest_algorithm, secret, authentication_service.nonce)
  end

  def set_facade
    @facade = DocFox::AccessToken::Facade.new(response.body)
  end
end
