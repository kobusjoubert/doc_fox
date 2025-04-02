# frozen_string_literal: true

class DocFox::AccessToken::Facade
  attr_reader :token, :expires_at

  def initialize(hash)
    attributes = hash.dig('data', 'attributes')

    @token      = attributes['token']
    @expires_at = attributes['expires_at']
  end
end
