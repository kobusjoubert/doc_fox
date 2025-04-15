# frozen_string_literal: true

class DocFox::Profile::GetService < DocFox::BaseService
  attr_reader :id, :params

  validates :id, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(id:, params: {})
    @id     = id
    @params = params
  end

  # Get a profile.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Profiles/paths/~1api~1v2~1profiles~1%7Bprofile_id%7D/get
  #
  # ==== Examples
  #
  #   service = DocFox::Profile::GetService.call(id: '')
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  #   service.facade # => #<DocFox::Profile::Facade ...>
  #   service.facade.id
  #   service.id
  #
  #   service.relationships.dig('names', 'data', 'id')
  #   service.relationships.dig('numbers', 'links', 'related')
  #
  # Include related resources.
  #
  #   service = DocFox::Profile::GetService.call(id: '', params: { include: 'names,numbers,additional_details' })
  #
  # GET /api/v2/profiles/:id
  def call
    connection.get("profiles/#{id}", **params)
  end

  private

  def set_facade
    @facade = DocFox::Profile::Facade.new(response.body)
  end
end
