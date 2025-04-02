# frozen_string_literal: true

class DocFox::User::ListService < DocFox::BaseService
  include DocFox::Enumerable

  # List users.
  #
  # ==== Examples
  #
  #   service = DocFox::User::ListService.call.first
  #   service.id
  #   service.email
  #
  # If you don't provide the `per_page` argument, multiple API requests will be made untill all records have been
  # returned. You could be rate limited, so use wisely.
  #
  #   DocFox::User::ListService.call(page: 1, per_page: 10).map { _1 }
  #
  # GET /api/v2/users
  def initialize(page: 1, per_page: Float::INFINITY)
    super(
      path:         'users',
      facade_klass: DocFox::User::Facade,
      page:         page,
      per_page:     per_page
    )
  end
end
