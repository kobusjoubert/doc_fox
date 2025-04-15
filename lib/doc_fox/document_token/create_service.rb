# frozen_string_literal: true

class DocFox::DocumentToken::CreateService < DocFox::BaseService
  attr_reader :document_id, :data

  validates :document_id, :data, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(document_id:, data:)
    @document_id = document_id
    @data        = data
  end

  # Create a document token.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Document-Tokens/paths/~1api~1v2~1documents~1%7Bdocument_id%7D~1document_tokens/post
  #
  # ==== Examples
  #
  #   service = DocFox::DocumentToken::CreateService.call(
  #     document_id: '',
  #     data: {
  #       type: 'document_token'
  #     }
  #   )
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 201
  #   service.response.body # => {}
  #
  #   service.facade # => #<DocFox::DocumentToken::Facade ...>
  #   service.facade.id
  #   service.id
  #
  # POST /api/v2/documents/:document_id/document_tokens
  def call
    connection.post("documents/#{document_id}/document_tokens", **params)
  end

  private

  def params
    {
      data: data
    }
  end

  def set_facade
    @facade = DocFox::DocumentToken::Facade.new(response.body)
  end
end
