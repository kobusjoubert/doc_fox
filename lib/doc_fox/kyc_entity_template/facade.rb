# frozen_string_literal: true

class DocFox::KycEntityTemplate::Facade
  attr_reader :id, :attributes, :created_at, :kyc_entity_type_name, :kyc_entity_type_category, :profile_schema,
    :updated_at

  def initialize(hash)
    @id         = hash.dig('data', 'id') || hash['id']
    @attributes = hash.dig('data', 'attributes') || hash['attributes']

    @created_at               = attributes['created_at']
    @kyc_entity_type_name     = attributes['kyc_entity_type_name']
    @kyc_entity_type_category = attributes['kyc_entity_type_category']
    @profile_schema           = attributes['profile_schema']
    @updated_at               = attributes['updated_at']
  end
end
