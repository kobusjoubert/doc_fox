# frozen_string_literal: true

class DocFox::DocumentToken::Facade
  attr_reader :id, :attributes, :content_type, :created_at, :expiry, :updated_at

  def initialize(hash)
    @id         = hash.dig('data', 'id') || hash['id']
    @attributes = hash.dig('data', 'attributes') || hash['attributes']

    @content_type = attributes['content_type']
    @created_at   = attributes['created_at']
    @expiry       = attributes['expiry']
    @updated_at   = attributes['updated_at']
  end
end
