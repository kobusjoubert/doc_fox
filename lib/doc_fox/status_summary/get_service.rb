# frozen_string_literal: true

class DocFox::StatusSummary::GetService < DocFox::BaseService
  attr_reader :id

  validates :id, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(id:)
    @id = id
  end

  # Get a status summary of a KYC application.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Status-Summaries/paths/~1api~1v2~1kyc_applications~1%7Bkyc_application_id%7D~1status_summaries/get
  #
  # ==== Examples
  #
  #   service = DocFox::StatusSummary::GetService.call(id: '')
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  #   service.facade # => #<DocFox::StatusSummary::Facade ...>
  #   service.facade.id
  #   service.id
  #
  #   service.relationships.dig('kyc_application', 'links', 'related')
  #
  # GET /api/v2/kyc_applications/:id/status_summaries
  def call
    connection.get("kyc_applications/#{id}/status_summaries")
  end

  private

  def set_facade
    @facade = DocFox::StatusSummary::Facade.new(response.body)
  end
end
