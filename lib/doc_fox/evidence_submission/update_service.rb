# frozen_string_literal: true

class DocFox::EvidenceSubmission::UpdateService < DocFox::BaseService
  attr_reader :id, :data

  validates :id, :data, presence: true

  after_call :set_facade

  delegate_missing_to :@facade

  def initialize(id:, data:)
    @id   = id
    @data = data
  end

  # Update an evidence submission.
  #
  # https://www.docfoxapp.com/api/v2/documentation#tag/Evidence-Submissions/paths/~1api~1v2~1evidence_submissions~1%7Bevidence_submission_id%7D/patch
  #
  # ==== Examples
  #
  #   service = DocFox::EvidenceSubmission::UpdateService.call(
  #     id: '',
  #     data: {
  #       type: 'evidence_submission',
  #       id: '',
  #       attributes: {
  #         results: {
  #           dob: '1984-01-01',
  #           gender: 'M',
  #           surname: 'Cartman',
  #           forename1: 'Eric',
  #           forename2: nil,
  #           id_number: '8401017223183',
  #           addresses: {
  #             address: [
  #               {
  #                 addr_type: 'R',
  #                 addr_line1: '28201 E. Bonanza St.',
  #                 addr_line2: '',
  #                 addr_line3: '',
  #                 addr_line4: 'South Park',
  #                 addr_postal_code: '8000',
  #                 addr_update_date: '2017-11-21'
  #               }
  #             ]
  #           },
  #           telephones: {
  #             telephone: [
  #               {
  #                 tel_num: '27715555555',
  #                 tel_type: 'Cell',
  #                 tel_update_date: '2017-09-05'
  #               }
  #             ]
  #           },
  #           deceased_date: nil,
  #           deceased_flag: 'N',
  #           verified_date: '2015-06-23',
  #           verified_flag: 'Y',
  #           deceased_reason: nil
  #         }
  #       }
  #     }
  #   )
  #
  #   service.success? # => true
  #   service.errors # => #<ActiveModel::Errors []>
  #
  #   service.response # => #<Faraday::Response ...>
  #   service.response.status # => 200
  #   service.response.body # => {}
  #
  #   service.facade # => #<DocFox::EvidenceSubmission::Facade ...>
  #   service.facade.id
  #   service.id
  #
  # PATCH /api/v2/evidence_submissions/:id
  def call
    connection.patch("evidence_submissions/#{id}", **params)
  end

  private

  def params
    {
      data: data
    }
  end

  def set_facade
    @facade = DocFox::EvidenceSubmission::Facade.new(response.body)
  end
end
