# frozen_string_literal: true

class DocFox::User::GetService < DocFox::BaseService
  attr_reader :id

  validates :id, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(id:)
    @id = id
  end

  # Get a user.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Users/paths/~1api~1v2~1users~1%7Buser_id%7D/get
  #
  # ==== Examples
  #
  #   service = DocFox::User::GetService.call(id: '')
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  #   service.facade # => #<DocFox::User::Facade ...>
  #   service.facade.id
  #   service.id
  #
  # GET /api/v2/users/:id
  def call
    connection.get("users/#{id}")
  end

  private

  def set_facade
    @facade = DocFox::User::Facade.new(response.body)
  end
end
