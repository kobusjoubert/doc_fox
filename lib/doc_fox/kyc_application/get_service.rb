# frozen_string_literal: true

class DocFox::KycApplication::GetService < DocFox::BaseService
  attr_reader :id, :params

  validates :id, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(id:, params: {})
    @id     = id
    @params = params
  end

  # Get a KYC application.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/KYC-Applications/paths/~1api~1v2~1kyc_applications~1%7Bkyc_application_id%7D/get
  #
  # ==== Examples
  #
  #   service = DocFox::KycApplication::GetService.call(id: '')
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
  #   service.relationships.dig('profile', 'data', 'id')
  #   service.relationships.dig('data_requirements', 'links', 'related')
  #
  # Include related resources.
  #
  #   service = DocFox::KycApplication::GetService.call(id: '', params: { include: 'managed_by,profile.names' })
  #   service.included
  #
  # GET /api/v2/kyc_applications/:id
  def call
    connection.get("kyc_applications/#{id}", **params)
  end

  private

  def set_facade
    @facade = DocFox::KycApplication::Facade.new(response.body)
  end
end
