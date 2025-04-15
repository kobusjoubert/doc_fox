# frozen_string_literal: true

class DocFox::Document::DownloadService < DocFox::BaseService
  CONTENT_TYPES = ['image/jpeg', 'image/png', 'application/pdf'].freeze

  attr_reader :document_id, :document_token_id, :content_type, :url
  private attr_reader :document_token_create_service

  validates :document_token_id_or_document_id, presence: true
  validates :content_type, presence: true, if: -> { document_token_id.present? }

  validates :content_type, on: :request,
    inclusion: {
      in:      CONTENT_TYPES,
      message: "has to be one of #{CONTENT_TYPES.to_sentence(last_word_connector: ' or ')}"
    }

  validate on: :request do
    if document_token_id.blank? && !document_token_create_service.success?
      errors.merge!(document_token_create_service.errors)
    end
  end

  before_call :create_document_token, :set_document_token_id_and_content_type, if: -> { document_token_id.blank? }

  def initialize(document_id: nil, document_token_id: nil, content_type: nil)
    @document_id       = document_id
    @document_token_id = document_token_id
    @content_type      = content_type
  end

  # Download a document file.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Download-Documents/paths/~1api~1v2~1document_file_downloads~1%7Bdocument_token_id%7D/get
  #
  # ==== Examples
  #
  #   service = DocFox::Document::DownloadService.call(document_token_id: '', content_type: 'image/png')
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => "\xFF\xD8\xFF\xDB\x00\x84\x00\x04\x05\x..."
  #
  # Possible values for `content_type`.
  #
  #   - `image/jpeg`
  #   - `image/png`
  #   - `application/pdf`
  #
  # You can also provide just the `document_id` and the service will automatically request the `document_token_id` and `content_type` for you.
  #
  #   service = DocFox::Document::DownloadService.call(document_id: '')
  #
  # GET /api/v2/document_file_downloads/:document_token_id
  def call
    connection.get("document_file_downloads/#{document_token_id}", nil, { 'Accept' => content_type })
  end

  private

  def document_token_id_or_document_id
    document_token_id.presence || document_id.presence
  end

  def create_document_token
    @document_token_create_service = DocFox::DocumentToken::CreateService.call(
      document_id: document_id,
      data:        { type: 'document_token' }
    )
  end

  def set_document_token_id_and_content_type
    return unless document_token_create_service.success?

    @document_token_id = document_token_create_service.id
    @content_type      = document_token_create_service.content_type
  end
end
