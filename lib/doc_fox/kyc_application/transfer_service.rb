# frozen_string_literal: true

class DocFox::KycApplication::TransferService < DocFox::BaseService
  attr_reader :id, :transfer_to_user_id

  validates :id, :transfer_to_user_id, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(id:, transfer_to_user_id:)
    @id                  = id
    @transfer_to_user_id = transfer_to_user_id
  end

  # Transfer a KYC application.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/KYC-Applications/paths/~1api~1v2~1kyc_applications~1%7Bkyc_application_id%7D~1transfer/patch
  #
  # ==== Examples
  #
  #   service = DocFox::KycApplication::TransferService.call(id: '', transfer_to_user_id: '')
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  #   service.facade # => #<DocFox::KycApplication::Facade ...>
  #   service.facade.id
  #   service.id
  #
  # PATCH /api/v2/kyc_applications/:id/transfer
  def call
    connection.patch("kyc_applications/#{id}/transfer", **params)
  end

  private

  def params
    {
      data: {
        type:       'kyc_application',
        id:         id,
        attributes: {
          transfer_to_user_id: transfer_to_user_id
        }
      }
    }
  end

  def set_facade
    @facade = DocFox::KycApplication::Facade.new(response.body)
  end
end
