# frozen_string_literal: true

class DocFox::KycApplication::ListService < DocFox::BaseService
  include DocFox::Enumerable

  attr_reader :search_term

  # List KYC applications.
  #
  # ==== Examples
  #
  #   service = DocFox::KycApplication::ListService.call.first
  #   service.id
  #   service.status
  #
  # If you don't provide the `per_page` argument, multiple API requests will be made untill all records have been
  # returned. You could be rate limited, so use wisely.
  #
  #   DocFox::KycApplication::ListService.call(page: 1, per_page: 10).map { _1 }
  #
  # Filter by names, numbers contact information or external refs.
  #
  #   DocFox::KycApplication::ListService.call(search_term: 'eric.cartman@example.com').map { _1 }
  #
  # GET /api/v2/kyc_applications
  def initialize(page: 1, per_page: Float::INFINITY, search_term: nil)
    @search_term = search_term

    super(
      path:         'kyc_applications',
      facade_klass: DocFox::KycApplication::Facade,
      page:         page,
      per_page:     per_page
    )
  end

  private

  def params
    @_params ||= begin
      params          = { page: page, per_page: max_per_page_per_request }
      params[:filter] = { search_term: search_term } if search_term.present?
      params
    end
  end
end
