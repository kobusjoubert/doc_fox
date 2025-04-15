# frozen_string_literal: true

class DocFox::BaseService < ActiveCall::Base
  include ActiveCall::Api

  self.abstract_class = true

  CACHE_KEY = { access_token: 'doc_fox/base_service/access_token' }.freeze

  config_accessor :base_url, default: 'https://www.docfoxapp.com/api/v2', instance_writer: false
  config_accessor :cache, default: ActiveSupport::Cache::MemoryStore.new, instance_writer: false
  config_accessor :logger, default: Logger.new($stdout), instance_writer: false
  config_accessor :log_level, default: :info, instance_writer: false
  config_accessor :log_headers, default: false, instance_writer: false
  config_accessor :log_bodies, default: false, instance_writer: false
  config_accessor :api_key, :secret, instance_writer: false

  attr_reader :access_token, :facade

  before_call :set_access_token

  validate on: :request do
    next if is_a?(DocFox::AccessToken::GetService) || is_a?(DocFox::Authentication::GetService)

    errors.merge!(access_token_service.errors) if access_token.nil? && !access_token_service.success?
  end

  class << self
    def exception_mapping
      {
        validation_error:              DocFox::ValidationError,
        request_error:                 DocFox::RequestError,
        client_error:                  DocFox::ClientError,
        server_error:                  DocFox::ServerError,
        bad_request:                   DocFox::BadRequestError,
        unauthorized:                  DocFox::UnauthorizedError,
        forbidden:                     DocFox::ForbiddenError,
        not_found:                     DocFox::NotFoundError,
        not_acceptable:                DocFox::NotAcceptableError,
        proxy_authentication_required: DocFox::ProxyAuthenticationRequiredError,
        request_timeout:               DocFox::RequestTimeoutError,
        conflict:                      DocFox::ConflictError,
        gone:                          DocFox::GoneError,
        unprocessable_entity:          DocFox::UnprocessableEntityError,
        too_many_requests:             DocFox::TooManyRequestsError,
        internal_server_error:         DocFox::InternalServerError,
        not_implemented:               DocFox::NotImplementedError,
        bad_gateway:                   DocFox::BadGatewayError,
        service_unavailable:           DocFox::ServiceUnavailableError,
        gateway_timeout:               DocFox::GatewayTimeoutError
      }.freeze
    end
  end

  private

  def connection
    @_connection ||= Faraday.new do |conn|
      conn.url_prefix = base_url
      conn.request :authorization, 'Bearer', access_token
      conn.request :json
      conn.request :retry
      conn.response :json
      conn.response :follow_redirects
      conn.response :logger, logger, **logger_options do |logger|
        logger.filter(/(Authorization:).*"(.+)."/i, '\1 [FILTERED]')
      end
      conn.adapter Faraday.default_adapter
    end
  end

  def logger_options
    {
      headers:   log_headers,
      log_level: log_level,
      bodies:    log_bodies,
      formatter: Faraday::Logging::ColorFormatter, prefix: { request: 'DocFox', response: 'DocFox' }
    }
  end

  def set_access_token
    @access_token = cache.read(CACHE_KEY[:access_token])
    return if @access_token.present?
    return unless access_token_service.success?

    expires_at = Time.parse(access_token_service.expires_at)

    @access_token = cache.fetch(CACHE_KEY[:access_token], expires_at: expires_at - 10) do
      access_token_service.token
    end
  end

  def access_token_service
    @_access_token_service ||= DocFox::AccessToken::GetService.call
  end
end
