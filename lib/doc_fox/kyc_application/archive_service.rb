# frozen_string_literal: true

class DocFox::KycApplication::ArchiveService < DocFox::BaseService
  attr_reader :id, :reason

  validates :id, :reason, presence: true

  def initialize(id:, reason:)
    @id     = id
    @reason = reason
  end

  # Archive a KYC application.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/KYC-Applications/paths/~1api~1v2~1kyc_applications~1%7Bkyc_application_id%7D~1archive/post
  #
  # ==== Examples
  #
  #   service = DocFox::KycApplication::ArchiveService.call(id: '', reason: '')
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 204
  #   service.response.body # => ""
  #
  # POST /api/v2/kyc_applications/:id/archive
  def call
    connection.post("kyc_applications/#{id}/archive", **params)
  end

  private

  def params
    {
      data: {
        type:       'application_archiving',
        attributes: {
          reason: reason
        }
      }
    }
  end
end
