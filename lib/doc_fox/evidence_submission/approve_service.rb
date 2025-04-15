# frozen_string_literal: true

class DocFox::EvidenceSubmission::ApproveService < DocFox::BaseService
  attr_reader :id

  validates :id, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(id:)
    @id = id
  end

  # Approve an active evidence submission.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Evidence-Submissions/paths/~1api~1v2~1evidence_submissions~1%7Bevidence_submission_id%7D~1approve/patch
  #
  # ==== Examples
  #
  #   service = DocFox::EvidenceSubmission::ApproveService.call(id: '')
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
  # PATCH /api/v2/kyc_applications/:id/approve
  def call
    connection.patch("evidence_submissions/#{id}/approve", **params)
  end

  private

  def params
    {
      data: {
        type: 'evidence_submission',
        id:   id
      }
    }
  end

  def set_facade
    @facade = DocFox::EvidenceSubmission::Facade.new(response.body)
  end
end
