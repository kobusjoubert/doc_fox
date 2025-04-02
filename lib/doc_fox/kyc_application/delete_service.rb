# frozen_string_literal: true

class DocFox::KycApplication::DeleteService < DocFox::BaseService
  attr_reader :id

  validates :id, presence: true

  def initialize(id:)
    @id = id
  end

  # Delete a KYC application.
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
