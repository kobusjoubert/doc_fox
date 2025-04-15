# frozen_string_literal: true

class DocFox::Profile::Facade
  attr_reader :id, :attributes, :relationships, :included, :created_at, :updated_at

  def initialize(hash)
    @id            = hash.dig('data', 'id') || hash['id']
    @attributes    = hash.dig('data', 'attributes') || hash['attributes']
    @relationships = hash.dig('data', 'relationships') || hash['relationships']
    @included      = hash['included']

    @created_at = attributes['created_at']
    @updated_at = attributes['updated_at']
  end
end
