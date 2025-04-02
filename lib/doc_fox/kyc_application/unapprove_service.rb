# frozen_string_literal: true

class DocFox::KycApplication::UnapproveService < DocFox::BaseService
  attr_reader :id, :reason

  validates :id, :reason, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(id:, reason:)
    @id     = id
    @reason = reason
  end

  # Unapprove a KYC application.
  #
  # ==== Examples
  #
  #   service = DocFox::KycApplication::UnapproveService.call(id: '', reason: '')
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
  # PATCH /api/v2/kyc_applications/:id/unapprove
  def call
    connection.patch("kyc_applications/#{id}/unapprove", **params)
  end

  private

  def params
    {
      data: {
        type:       'kyc_application',
        id:         id,
        attributes: {
          reason: reason
        }
      }
    }
  end

  def set_facade
    @facade = DocFox::KycApplication::Facade.new(response.body)
  end
end
