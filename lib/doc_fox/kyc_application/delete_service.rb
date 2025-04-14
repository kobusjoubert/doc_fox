# frozen_string_literal: true

class DocFox::KycApplication::DeleteService < DocFox::BaseService
  attr_reader :id

  validates :id, presence: true

  def initialize(id:)
    @id = id
  end

  # Delete a KYC application.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/KYC-Applications/paths/~1api~1v2~1kyc_applications~1%7Bkyc_application_id%7D/delete
  #
  # ==== Examples
  #
  #   service = DocFox::KycApplication::DeleteService.call(id: '')
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 204
  #   service.response.body # => ""
  #
  # DELETE /api/v2/kyc_applications/:id
  def call
    connection.delete("kyc_applications/#{id}")
  end
end
