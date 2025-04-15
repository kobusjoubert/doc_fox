# frozen_string_literal: true

class DocFox::Document::Facade
  attr_reader :id, :attributes, :relationships, :included, :content_type, :created_at, :data_capture_fields, :filename,
    :token, :token_expiry, :uploaded_by, :updated_at

  def initialize(hash)
    @id            = hash.dig('data', 'id') || hash['id']
    @attributes    = hash.dig('data', 'attributes') || hash['attributes']
    @relationships = hash.dig('data', 'relationships') || hash['relationships']
    @included      = hash['included']

    @content_type        = attributes['content_type']
    @created_at          = attributes['created_at']
    @data_capture_fields = attributes['data_capture_fields']
    @filename            = attributes['filename']
    @token               = attributes['token']
    @token_expiry        = attributes['token_expiry']
    @uploaded_by         = attributes['uploaded_by']
    @updated_at          = attributes['updated_at']
  end
end
