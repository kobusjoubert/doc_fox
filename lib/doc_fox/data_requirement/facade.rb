# frozen_string_literal: true

class DocFox::DataRequirement::Facade
  attr_reader :id, :attributes, :relationships, :included, :created_at, :duplicable, :duplicates_max, :duplicates_min,
    :duplicate_of, :form, :name, :required, :slug, :updated_at, :valid_evidence_types

  def initialize(hash)
    @id            = hash.dig('data', 'id') || hash['id']
    @attributes    = hash.dig('data', 'attributes') || hash['attributes']
    @relationships = hash.dig('data', 'relationships') || hash['relationships']
    @included      = hash['included']

    @created_at           = attributes['created_at']
    @duplicable           = attributes['duplicable']
    @duplicates_max       = attributes['duplicates_max']
    @duplicates_min       = attributes['duplicates_min']
    @duplicate_of         = attributes['duplicate_of']
    @form                 = attributes['form']
    @name                 = attributes['name']
    @required             = attributes['required']
    @slug                 = attributes['slug']
    @updated_at           = attributes['updated_at']
    @valid_evidence_types = attributes['valid_evidence_types']
  end
end
