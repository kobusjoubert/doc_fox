# frozen_string_literal: true

class DocFox::EvidenceSubmission::ListService < DocFox::BaseService
  include DocFox::Enumerable

  attr_reader :data_requirement_id

  validates :data_requirement_id, presence: true

  # List evidence submissions.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Evidence-Submissions/paths/~1api~1v2~1data_requirements~1%7Bdata_requirement_id%7D~1evidence_submissions/get
  #
  # ==== Examples
  #
  #   service = DocFox::EvidenceSubmission::ListService.call(data_requirement_id: '').first
  #   service.id
  #   service.status
  #
  # If you don't provide the `per_page` argument, multiple API requests will be made untill all records have been
  # returned. You could be rate limited, so use wisely.
  #
  #   DocFox::EvidenceSubmission::ListService.call(data_requirement_id: '', page: 1, per_page: 10).map { _1 }
  #
  # GET /api/v2/data_requirements/:data_requirement_id/evidence_submissions
  def initialize(data_requirement_id:, page: 1, per_page: Float::INFINITY)
    @data_requirement_id = data_requirement_id

    super(
      path:         "data_requirements/#{data_requirement_id}/evidence_submissions",
      facade_klass: DocFox::EvidenceSubmission::Facade,
      page:         page,
      per_page:     per_page
    )
  end
end
