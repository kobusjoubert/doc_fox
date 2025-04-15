# frozen_string_literal: true

class DocFox::EvidenceSubmission::GetService < DocFox::BaseService
  attr_reader :id, :params

  validates :id, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(id:, params: {})
    @id     = id
    @params = params
  end

  # Get an evidence submission.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Evidence-Submissions/paths/~1api~1v2~1evidence_submissions~1%7Bevidence_submission_id%7D/get
  #
  # ==== Examples
  #
  #   service = DocFox::EvidenceSubmission::GetService.call(id: '')
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  #   service.facade # => #<DocFox::EvidenceSubmission::Facade ...>
  #   service.facade.id
  #   service.id
  #
  #   service.relationships.dig('document', 'data')
  #   service.relationships.dig('data_requirement', 'links', 'related')
  #
  # Include related resources.
  #
  #   service = DocFox::EvidenceSubmission::GetService.call(id: '', params: { include: 'document,qualitative_checks' })
  #   service.included
  #
  # GET /api/v2/evidence_submissions/:id
  def call
    connection.get("evidence_submissions/#{id}", **params)
  end

  private

  def set_facade
    @facade = DocFox::EvidenceSubmission::Facade.new(response.body)
  end
end
