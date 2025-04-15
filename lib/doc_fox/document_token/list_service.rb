# frozen_string_literal: true

class DocFox::DocumentToken::ListService < DocFox::BaseService
  include DocFox::Enumerable

  attr_reader :document_id

  validates :document_id, presence: true

  # List document tokens.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Document-Tokens/paths/~1api~1v2~1documents~1%7Bdocument_id%7D~1document_tokens/get
  #
  # ==== Examples
  #
  #   service = DocFox::DocumentToken::ListService.call(document_id: '').first
  #   service.id
  #   service.expiry
  #
  # If you don't provide the `per_page` argument, multiple API requests will be made untill all records have been
  # returned. You could be rate limited, so use wisely.
  #
  #   DocFox::DocumentToken::ListService.call(document_id: '', page: 1, per_page: 10).map { _1 }
  #
  # GET /api/v2/documents/:document_id/document_tokens
  def initialize(document_id:, page: 1, per_page: Float::INFINITY)
    @document_id = document_id

    super(
      path:         "documents/#{document_id}/document_tokens",
      facade_klass: DocFox::DocumentToken::Facade,
      page:         page,
      per_page:     per_page
    )
  end
end
