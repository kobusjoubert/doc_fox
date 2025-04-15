# frozen_string_literal: true

class DocFox::StatusSummary::Facade
  attr_reader :id, :attributes, :relationships, :overall_kyc_application_status, :module_statuses

  def initialize(hash)
    @id            = hash.dig('data', 'id')
    @attributes    = hash.dig('data', 'attributes')
    @relationships = hash.dig('data', 'relationships')

    @overall_kyc_application_status = attributes['overall_kyc_application_status']
    @module_statuses                = attributes['module_statuses']
  end
end
