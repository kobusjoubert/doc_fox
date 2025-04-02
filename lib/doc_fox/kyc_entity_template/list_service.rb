# frozen_string_literal: true

class DocFox::KycEntityTemplate::ListService < DocFox::BaseService
  include DocFox::Enumerable

  # List KYC entity templates.
  #
  # ==== Examples
  #
  #   service = DocFox::KycEntityTemplate::ListService.call.first
  #   service.id
  #   service.kyc_entity_type_name
  #
  # If you don't provide the `per_page` argument, multiple API requests will be made untill all records have been
  # returned. You could be rate limited, so use wisely.
  #
  #   DocFox::KycEntityTemplate::ListService.call(page: 1, per_page: 10).map { _1 }
  #
  # GET /api/v2/kyc_entity_templates
  def initialize(page: 1, per_page: Float::INFINITY)
    super(
      path:         'kyc_entity_templates',
      facade_klass: DocFox::KycEntityTemplate::Facade,
      page:         page,
      per_page:     per_page
    )
  end
end
