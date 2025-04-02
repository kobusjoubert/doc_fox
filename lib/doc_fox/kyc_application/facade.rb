# frozen_string_literal: true

class DocFox::KycApplication::Facade
  attr_reader :id, :attributes, :relationships, :included, :approved_at, :archived, :archived_reason, :created_at,
    :kyc_entity_type_name, :renew_at, :status, :updated_at

  def initialize(hash)
    @id            = hash.dig('data', 'id') || hash['id']
    @attributes    = hash.dig('data', 'attributes') || hash['attributes']
    @relationships = hash.dig('data', 'relationships') || hash['relationships']
    @included      = hash['included']

    @approved_at          = attributes['approved_at']
    @archived             = attributes['archived']
    @archived_reason      = attributes['archived_reason']
    @created_at           = attributes['created_at']
    @kyc_entity_type_name = attributes['kyc_entity_type_name']
    @renew_at             = attributes['renew_at']
    @status               = attributes['status']
    @updated_at           = attributes['updated_at']
  end
end
