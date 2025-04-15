# frozen_string_literal: true

class DocFox::EvidenceSubmission::RejectService < DocFox::BaseService
  attr_reader :id, :reason

  validates :id, :reason, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(id:, reason:)
    @id     = id
    @reason = reason
  end

  # Reject an active evidence submission.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Evidence-Submissions/paths/~1api~1v2~1evidence_submissions~1%7Bevidence_submission_id%7D~1reject/patch
  #
  # ==== Examples
  #
  #   service = DocFox::EvidenceSubmission::RejectService.call(id: '', reason: '')
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
  # PATCH /api/v2/kyc_applications/:id/archive
  def call
    connection.patch("evidence_submissions/#{id}/reject", **params)
  end

  private

  def params
    {
      data: {
        type:       'evidence_submission',
        id:         id,
        attributes: {
          rejection_reason: reason
        }
      }
    }
  end

  def set_facade
    @facade = DocFox::EvidenceSubmission::Facade.new(response.body)
  end
end
