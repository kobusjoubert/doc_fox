# frozen_string_literal: true

class DocFox::DataRequirement::ListService < DocFox::BaseService
  include DocFox::Enumerable

  attr_reader :kyc_application_id, :account_application_id, :forms

  validates :kyc_application_id_or_account_application_id, presence: true

  # List data requirements.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Data-Requirements/paths/~1api~1v2~1kyc_applications~1%7Bkyc_application_id%7D~1data_requirements/get
  #
  # List data requirements associated with an account application.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Data-Requirements/paths/~1api~1v2~1account_applications~1%7Baccount_application_id%7D~1data_requirements/get
  #
  # ==== Examples
  #
  #   service = DocFox::DataRequirement::ListService.call(kyc_application_id: '').first
  #   service.id
  #   service.name
  #
  #   service = DocFox::DataRequirement::ListService.call(account_application_id: '').first
  #   service.id
  #   service.name
  #
  # If you don't provide the `per_page` argument, multiple API requests will be made untill all records have been
  # returned. You could be rate limited, so use wisely.
  #
  #   DocFox::DataRequirement::ListService.call(kyc_application_id: '', page: 1, per_page: 10).map { _1 }
  #
  # Filter by forms.
  #
  #   DocFox::DataRequirement::ListService.call(kyc_application_id: '', forms: true).map { _1 }
  #
  # GET /api/v2/kyc_applications/:kyc_application_id/data_requirements
  # GET /api/v2/account_applications/:account_application_id/data_requirements
  def initialize(kyc_application_id: nil, account_application_id: nil, page: 1, per_page: Float::INFINITY, forms: false)
    @kyc_application_id     = kyc_application_id
    @account_application_id = account_application_id
    @forms                  = forms

    entity_path = kyc_application_id.present? ? 'kyc_applications' : 'account_applications'

    super(
      path:         "#{entity_path}/#{kyc_application_id_or_account_application_id}/data_requirements",
      facade_klass: DocFox::DataRequirement::Facade,
      page:         page,
      per_page:     per_page
    )
  end

  private

  def params
    @_params ||= begin
      params         = { page: page, per_page: max_per_page_per_request }
      params[:forms] = true if forms == true
      params
    end
  end

  def kyc_application_id_or_account_application_id
    kyc_application_id.presence || account_application_id.presence
  end
end
