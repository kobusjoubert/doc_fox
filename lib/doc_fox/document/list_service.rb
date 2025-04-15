# frozen_string_literal: true

class DocFox::Document::ListService < DocFox::BaseService
  include DocFox::Enumerable

  attr_reader :evidence_submission_id

  validates :evidence_submission_id, presence: true

  # List documents.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Documents/paths/~1api~1v2~1evidence_submissions~1%7Bevidence_submission_id%7D~1documents/get
  #
  # ==== Examples
  #
  #   service = DocFox::Document::ListService.call(evidence_submission_id: '').first
  #   service.id
  #   service.filename
  #
  # If you don't provide the `per_page` argument, multiple API requests will be made untill all records have been
  # returned. You could be rate limited, so use wisely.
  #
  #   DocFox::Document::ListService.call(evidence_submission_id: '', page: 1, per_page: 10).map { _1 }
  #
  # GET /api/v2/evidence_submissions/:evidence_submission_id/documents
  def initialize(evidence_submission_id:, page: 1, per_page: Float::INFINITY)
    @evidence_submission_id = evidence_submission_id

    super(
      path:         "evidence_submissions/#{evidence_submission_id}/documents",
      facade_klass: DocFox::Document::Facade,
      page:         page,
      per_page:     per_page
    )
  end
end
