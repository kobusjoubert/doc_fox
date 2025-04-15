# frozen_string_literal: true

class DocFox::Document::GetService < DocFox::BaseService
  attr_reader :id, :params

  validates :id, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(id:, params: {})
    @id     = id
    @params = params
  end

  # Get a document.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Documents/paths/~1api~1v2~1documents~1%7Bdocument_id%7D/get
  #
  # ==== Examples
  #
  #   service = DocFox::Document::GetService.call(id: '')
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  #   service.facade # => #<DocFox::Document::Facade ...>
  #   service.facade.id
  #   service.id
  #
  #   service.relationships.dig('evidence_submissions', 'data')
  #   service.relationships.dig('document_tokens', 'links', 'related')
  #
  # Include related resources.
  #
  #   service = DocFox::Document::GetService.call(id: '', params: { include: 'evidence_submissions' })
  #   service.included
  #
  # GET /api/v2/documents/:id
  def call
    connection.get("documents/#{id}", **params)
  end

  private

  def set_facade
    @facade = DocFox::Document::Facade.new(response.body)
  end
end
