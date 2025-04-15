# frozen_string_literal: true

class DocFox::DocumentToken::GetService < DocFox::BaseService
  attr_reader :id, :params

  validates :id, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(id:, params: {})
    @id     = id
    @params = params
  end

  # Get a document token.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Document-Tokens/paths/~1api~1v2~1document_tokens~1%7Bdocument_token_id%7D/get
  #
  # ==== Examples
  #
  #   service = DocFox::DocumentToken::GetService.call(id: '')
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  #   service.facade # => #<DocFox::DocumentToken::Facade ...>
  #   service.facade.id
  #   service.id
  #
  # GET /api/v2/document_tokens/:id
  def call
    connection.get("document_tokens/#{id}", **params)
  end

  private

  def set_facade
    @facade = DocFox::DocumentToken::Facade.new(response.body)
  end
end
