# frozen_string_literal: true

class DocFox::KycApplication::CreateService < DocFox::BaseService
  attr_reader :data

  validates :data, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(data:)
    @data = data
  end

  # Create a KYC application.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/KYC-Applications/paths/~1api~1v2~1kyc_applications/post
  #
  # ==== Examples
  #
  #   service = DocFox::KycApplication::CreateService.call(
  #     data: {
  #       type: 'kyc_application',
  #       attributes: {
  #         kyc_entity_template_id: 'aaaaaaaa-1111-2222-3333-bbbbbbbbbbbb',
  #         names: {
  #           first_names: 'Eric Theodore',
  #           last_names: 'Cartman'
  #         },
  #         # ...more fields following the schema definitions.
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
  #   service.facade # => #<DocFox::KycApplication::Facade ...>
  #   service.facade.id
  #   service.id
  #
  # POST /api/v2/kyc_applications
  def call
    connection.post('kyc_applications', **params)
  end

  private

  def params
    {
      data: data
    }
  end

  def set_facade
    @facade = DocFox::KycApplication::Facade.new(response.body)
  end
end
