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

  attr_reader :facade

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
      conn.adapter Faraday.default_adapter
      conn.url_prefix = base_url
      conn.request :authorization, 'Bearer', -> { access_token }
      conn.request :json
      conn.request :retry
      conn.response :json
      conn.response :logger, logger, **logger_options do |logger|
        logger.filter(/(Authorization:).*"(.+)."/i, '\1 [FILTERED]')
      end
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

  def access_token
    access_token = cache.read(CACHE_KEY[:access_token])
    return access_token if access_token.present?

    service = DocFox::AccessToken::GetService.call
    cache.fetch(CACHE_KEY[:access_token], expires_at: Time.parse(service.expires_at) - 10) { service.token }
  end
end
