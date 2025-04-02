# frozen_string_literal: true

class DocFox::KycApplication::ApproveService < DocFox::BaseService
  attr_reader :id

  validates :id, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(id:)
    @id = id
  end

  # Approve a KYC application.
  #
  # ==== Examples
  #
  #   service = DocFox::KycApplication::ApproveService.call(id: '')
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
  # PATCH /api/v2/kyc_applications/:id/approve
  def call
    connection.patch("kyc_applications/#{id}/approve", **params)
  end

  private

  def params
    {
      data: {
        type:       'kyc_application',
        id:         id,
        attributes: {}
      }
    }
  end

  def set_facade
    @facade = DocFox::KycApplication::Facade.new(response.body)
  end
end
