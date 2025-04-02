# frozen_string_literal: true

class DocFox::Authentication::GetService < DocFox::BaseService
  after_call :set_facade

  delegate_missing_to :@facade

  # Get access token.
  #
  # ==== Examples
  #
  #   service = DocFox::Authentication::GetService.call
  #   service.nonce # => ''
  #   service.digest_algorithm # => ''
  #
  # GET /api/v2/authentications/new
  def call
    connection.get('authentications/new')
  end

  private

  def connection
    @_connection ||= Faraday.new do |conn|
      conn.adapter Faraday.default_adapter
      conn.url_prefix = base_url
      conn.headers['X-Client-Api-Key'] = api_key
      conn.request :json
      conn.request :retry
      conn.response :json
      conn.response :logger, logger, **logger_options do |logger|
        logger.filter(/(X-Client-Api-Key:).*"(.+)."/i, '\1 [FILTERED]')
        logger.filter(/"nonce":"([^"]+)"/i, '"nonce":"[FILTERED]"')
      end
    end
  end

  def set_facade
    @facade = DocFox::Authentication::Facade.new(response.body)
  end
end
