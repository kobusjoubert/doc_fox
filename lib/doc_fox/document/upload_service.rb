# frozen_string_literal: true

class DocFox::Document::UploadService < DocFox::BaseService
  attr_reader :evidence_submission_id, :data

  validates :evidence_submission_id, :data, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(evidence_submission_id:, data:)
    @evidence_submission_id = evidence_submission_id
    @data                   = data
  end

  # Upload a document file.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Document-Uploads/paths/~1api~1v2~1evidence_submissions~1%7Bevidence_submission_id%7D~1documents/post
  #
  # ==== Examples
  #
  #   service = DocFox::Document::UploadService.call(
  #     evidence_submission_id: '',
  #     data: {
  #       type: 'document',
  #       attributes: {
  #         evidence_type: 'taxes_paid_in_prior_quarter',
  #         filename: 'taxes_paid.png',
  #         document_data: "data:image/png;base64,#{Base64.encode64(File.read('/path/to/taxes_paid.png'))}"
  #       }
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
  #   service.facade # => #<DocFox::Document::Facade ...>
  #   service.facade.id
  #   service.id
  #
  # POST /api/v2/evidence_submissions/:evidence_submission_id/documents
  def call
    connection.post("evidence_submissions/#{evidence_submission_id}/documents", **params)
  end

  private

  def params
    {
      data: data
    }
  end

  def set_facade
    @facade = DocFox::Document::Facade.new(response.body)
  end
end
