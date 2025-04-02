# frozen_string_literal: true

class DocFox::KycApplication::GetService < DocFox::BaseService
  attr_reader :id, :params

  after_call :set_facade

  delegate_missing_to :@facade

  validates :id, presence: true

  def initialize(id:, params: {})
    @id     = id
    @params = params
  end

  # Get a KYC application.
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
    connection.get("kyc_applications/#{id}", params)
  end

  private

  def set_facade
    @facade = DocFox::KycApplication::Facade.new(response.body)
  end
end
