# frozen_string_literal: true

class DocFox::Profile::ListService < DocFox::BaseService
  include DocFox::Enumerable

  attr_reader :kyc_application_id

  validates :kyc_application_id, presence: true

  # List profiles.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Profiles/paths/~1api~1v2~1kyc_applications~1%7Bkyc_application_id%7D~1profiles/get
  #
  # ==== Examples
  #
  #   service = DocFox::Profile::ListService.call(kyc_application_id: '').first
  #   service.id
  #   service.created_at
  #
  # If you don't provide the `per_page` argument, multiple API requests will be made untill all records have been
  # returned. You could be rate limited, so use wisely.
  #
  #   DocFox::Profile::ListService.call(kyc_application_id: '', page: 1, per_page: 10).map { _1 }
  #
  # GET /api/v2/kyc_applications/:kyc_application_id/profiles
  def initialize(kyc_application_id:, page: 1, per_page: Float::INFINITY)
    @kyc_application_id = kyc_application_id

    super(
      path:         "kyc_applications/#{kyc_application_id}/profiles",
      facade_klass: DocFox::Profile::Facade,
      page:         page,
      per_page:     per_page
    )
  end
end
