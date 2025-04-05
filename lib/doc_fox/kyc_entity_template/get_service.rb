# frozen_string_literal: true

class DocFox::KycEntityTemplate::GetService < DocFox::BaseService
  attr_reader :id

  validates :id, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(id:)
    @id = id
  end

  # Get a KYC application.
  #
  # ==== Examples
  #
  #   service = DocFox::KycEntityTemplate::GetService.call(id: '')
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  #   service.facade # => #<DocFox::KycEntityTemplate::Facade ...>
  #   service.facade.id
  #   service.id
  #
  # GET /api/v2/kyc_entity_templates/:id
  def call
    connection.get("kyc_entity_templates/#{id}")
  end

  private

  def set_facade
    @facade = DocFox::KycEntityTemplate::Facade.new(response.body)
  end
end
