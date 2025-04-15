# frozen_string_literal: true

class DocFox::DataRequirement::GetService < DocFox::BaseService
  attr_reader :id, :params

  validates :id, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(id:, params: {})
    @id     = id
    @params = params
  end

  # Get a data requirement.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Data-Requirements/paths/~1api~1v2~1data_requirements~1%7Bdata_requirement_id%7D/get
  #
  # ==== Examples
  #
  #   service = DocFox::DataRequirement::GetService.call(id: '')
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  #   service.facade # => #<DocFox::DataRequirement::Facade ...>
  #   service.facade.id
  #   service.id
  #
  #   service.relationships.dig('kyc_application', 'data', 'id')
  #   service.relationships.dig('active_evidence_submission', 'links', 'related')
  #
  # Include related resources.
  #
  #   service = DocFox::DataRequirement::GetService.call(id: '', params: { include: 'evidence_submissions,active_evidence_submission' })
  #
  # GET /api/v2/data_requirements/:id
  def call
    connection.get("data_requirements/#{id}", **params)
  end

  private

  def set_facade
    @facade = DocFox::DataRequirement::Facade.new(response.body)
  end
end
