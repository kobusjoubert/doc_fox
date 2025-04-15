# Active Call - nCino KYC DocFox

[![Gem Version](https://badge.fury.io/rb/active_call-doc_fox.svg?icon=si%3Arubygems)](https://badge.fury.io/rb/active_call-doc_fox)

DocFox exposes the [nCino KYC DocFox API](https://www.docfoxapp.com/api/v2/documentation) endpoints through service objects.

- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Using call](#using-call)
  - [Using call!](#using-call!)
  - [When to use call or call!](#using-call-or-call!)
  - [Using lists](#using-lists)
- [Service Objects](#service-objects)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add active_call-doc_fox
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install active_call-doc_fox
```

## Configuration

Configure your API credentials.

In a Rails application, the standard practice is to place this code in a file named `doc_fox.rb` within the `config/initializers` directory.

```ruby
require 'active_call-doc_fox'

DocFox::BaseService.configure do |config|
  config.api_key = ''
  config.secret = ''

  # Optional configuration.
  config.cache = Rails.cache # Default: ActiveSupport::Cache::MemoryStore.new
  config.logger = Rails.logger # Default: Logger.new($stdout)
  config.logger_level = :debug # Default: :info
  config.log_headers = true # Default: false
  config.log_bodies = true # Default: false
end
```

## Usage

### <a name='using-call'></a>Using `call`

Each service object returned will undergo validation before the `call` method is invoked to access API endpoints.

After **successful** validation.

```ruby
service.success? # => true
service.errors # => #<ActiveModel::Errors []>
```

After **failed** validation.

```ruby
service.success? # => false
service.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=id, type=blank, options={}>]>
service.errors.full_messages # => ["Id can't be blank"]
```

After a **successful** `call` invocation, the `response` attribute will contain a `Faraday::Response` object.

```ruby
service.success? # => true
service.response # => #<Faraday::Response ...>
service.response.success? # => true
service.response.status # => 200
service.response.body # => {"data"=>{"id"=>"aaaaaaaa-1111-2222-3333-bbbbbbbbbbbb", "type"=>"kyc_application", "attributes"=>{}}, ...}
```

At this point you will also have a `facade` object which will hold all the attributes for the specific resource.

```ruby
service.facade # => #<DocFox::KycApplication::Facade @kyc_entity_type_name="South African Citizen" ...>
service.facade.kyc_entity_type_name # => 'South African Citizen'
```

For convenience, facade attributes can be accessed directly on the service object.

```ruby
service.kyc_entity_type_name # => 'South African Citizen'
```

After a **failed** `call` invocation, the `response` attribute will still contain a `Faraday::Response` object.

```ruby
service.success? # => false
service.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=base, type=not_found, options={}>]>
service.errors.full_messages # => ["Not Found"]
service.response # => #<Faraday::Response ...>
service.response.success? # => false
service.response.status # => 404
service.response.body # => {"errors"=>[{"title"=>"not_found", "status"=>"404", "detail"=>"The resource you requested could not be found"}]}
```

### <a name='using-call!'></a>Using `call!`

Each service object returned will undergo validation before the `call!` method is invoked to access API endpoints.

After **successful** validation.

```ruby
service.success? # => true
```

After **failed** validation, a `DocFox::ValidationError` exception will be raised with an `errors` attribute which 
will contain an `ActiveModel::Errors` object.

```ruby
rescue DocFox::ValidationError => exception
  exception.message # => ''
  exception.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=id, type=blank, options={}>]>
  exception.errors.full_messages # => ["Id can't be blank"]
```

After a **successful** `call!` invocation, the `response` attribute will contain a `Faraday::Response` object.

```ruby
service.success? # => true
service.response # => #<Faraday::Response ...>
service.response.success? # => true
service.response.status # => 200
service.response.body # => {"data"=>{"id"=>"aaaaaaaa-1111-2222-3333-bbbbbbbbbbbb", "type"=>"kyc_application", "attributes"=>{}}, ...}
```

At this point you will also have a `facade` object which will hold all the attributes for the specific resource.

```ruby
service.facade # => #<DocFox::KycApplication::Facade @kyc_entity_type_name="South African Citizen" ...>
service.facade.kyc_entity_type_name # => 'South African Citizen'
```

For convenience, facade attributes can be accessed directly on the service object.

```ruby
service.kyc_entity_type_name # => 'South African Citizen'
```

After a **failed** `call!` invocation, a `DocFox::RequestError` will be raised with a `response` attribute which will contain a `Faraday::Response` object.

```ruby
rescue DocFox::RequestError => exception
  exception.message # => 'Not Found'
  exception.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=base, type=not_found, options={}>]>
  exception.errors.full_messages # => ["Not Found"]
  exception.response # => #<Faraday::Response ...>
  exception.response.status # => 404
  exception.response.body # => {"errors"=>[{"title"=>"not_found", "status"=>"404", "detail"=>"The resource you requested could not be found"}]}
```

### <a name='using-call-or-call!'></a>When to use `call` or `call!`

An example of where to use `call` would be in a **controller** doing an inline synchronous request.

```ruby
class SomeController < ApplicationController
  def update
    @service = DocFox::KycApplication::UpdateService.call(**params)

    if @service.success?
      redirect_to [@service], notice: 'Success', status: :see_other
    else
      flash.now[:alert] = @service.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end
end
```

An example of where to use `call!` would be in a **job** doing an asynchronous request.

You can use the exceptions to determine which retry strategy to use and which to discard.

```ruby
class SomeJob < ApplicationJob
  discard_on DocFox::NotFoundError

  retry_on DocFox::RequestTimeoutError, wait: 5.minutes, attempts: :unlimited
  retry_on DocFox::TooManyRequestsError, wait: :polynomially_longer, attempts: 10

  def perform
    DocFox::KycApplication::UpdateService.call!(**params)
  end
end
```

### Using lists

If you don't provide the `per_page` argument, multiple API requests will be made untill all records have been returned. You could be rate limited, so use wisely.

## Service Objects

<details open>
<summary>KYC Applications</summary>

### KYC Applications

#### List KYC applications

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/KYC-Applications/paths/~1api~1v2~1kyc_applications/get

DocFox::KycApplication::ListService.call(page: 1, per_page: 10).each do |facade|
  facade.id
end
```

Filter by names, numbers contact information or external refs.

```ruby
DocFox::KycApplication::ListService.call(search_term: 'eric.cartman@example.com').map { _1 }
```

#### Get a KYC application

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/KYC-Applications/paths/~1api~1v2~1kyc_applications~1%7Bkyc_application_id%7D/get

service = DocFox::KycApplication::GetService.call(id: '')
service.id
service.approved_at
service.archived
service.created_at
service.status
service.relationships.dig('profile', 'data', 'id')
service.relationships.dig('data_requirements', 'links', 'related')
...
```

Include related resources.

`managed_by`, `profile.additional_details`, `profile.addresses`, `profile.contacts`, `profile.names`, `profile.numbers`, `parent_related_entities`, `onboarding_token_summary`, `onboarding_token_summary.status_summaries`, `onboarding_token_summary.data_requirement_summaries`, `onboarding_token_summary.kyc_entity_template_designation_schema`, `onboarding_token_summary.parent_related_entity_designation_summary`, `onboarding_token_summary.parent_onboarding_token_summary`, `onboarding_token_summary.relationship_builder_config`

```ruby
service = DocFox::KycApplication::GetService.call(id: '', params: { include: 'managed_by,profile.names' })
service.included
```

#### Create a KYC application

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/KYC-Applications/paths/~1api~1v2~1kyc_applications/post

DocFox::KycApplication::CreateService.call(
  data: {
    type: 'kyc_application',
    attributes: {
      kyc_entity_template_id: 'aaaaaaaa-1111-2222-3333-bbbbbbbbbbbb',
      names: {
        first_names: 'Eric Theodore',
        last_names: 'Cartman'
      },
      # ...more fields following the schema definitions.
    }
  }
)
```

#### Approve a KYC application

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/KYC-Applications/paths/~1api~1v2~1kyc_applications~1%7Bkyc_application_id%7D~1approve/patch

DocFox::KycApplication::ApproveService.call(id: '')
```

#### Unapprove a KYC application

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/KYC-Applications/paths/~1api~1v2~1kyc_applications~1%7Bkyc_application_id%7D~1unapprove/patch

DocFox::KycApplication::UnapproveService.call(id: '', reason: '')
```

#### Transfer a KYC application

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/KYC-Applications/paths/~1api~1v2~1kyc_applications~1%7Bkyc_application_id%7D~1transfer/patch

DocFox::KycApplication::TransferService.call(id: '', transfer_to_user_id: '')
```

#### Archive a KYC application

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/KYC-Applications/paths/~1api~1v2~1kyc_applications~1%7Bkyc_application_id%7D~1archive/post

DocFox::KycApplication::ArchiveService.call(id: '', reason: '')
```

#### Unarchive a KYC application

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/KYC-Applications/paths/~1api~1v2~1kyc_applications~1%7Bkyc_application_id%7D~1unarchive/post

DocFox::KycApplication::UnarchiveService.call(id: '', reason: '')
```

#### Delete a KYC application

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/KYC-Applications/paths/~1api~1v2~1kyc_applications~1%7Bkyc_application_id%7D/delete

DocFox::KycApplication::DeleteService.call(id: '')
```

</details>

<details>
<summary>Status Summaries</summary>

### Status Summaries

#### Get a status summary of a KYC application

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Status-Summaries/paths/~1api~1v2~1kyc_applications~1%7Bkyc_application_id%7D~1status_summaries/get

service = DocFox::StatusSummary::GetService.call(id: '')
service.id
service.overall_kyc_application_status
service.module_statuses
...
```

</details>

<details>
<summary>Profiles</summary>

### Profiles

#### List profiles

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Profiles/paths/~1api~1v2~1kyc_applications~1%7Bkyc_application_id%7D~1profiles/get

DocFox::Profile::ListService.call(kyc_application_id: '', page: 1, per_page: 10).each do |facade|
  facade.id
end
```

#### Get a profile

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Profiles/paths/~1api~1v2~1profiles~1%7Bprofile_id%7D/get

service = DocFox::Profile::GetService.call(id: '')
service.id
service.created_at
...
```

Include related resources.

`additional_details`, `addresses`, `contacts`, `contacts.invitation_tokens`, `names`, `numbers`

```ruby
service = DocFox::Profile::GetService.call(id: '', params: { include: 'names,numbers,additional_details' })
service.included
```

</details>

<details>
<summary>Data Requirements</summary>

### Data Requirements

#### List data requirements

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Data-Requirements/paths/~1api~1v2~1kyc_applications~1%7Bkyc_application_id%7D~1data_requirements/get

DocFox::DataRequirement::ListService.call(kyc_application_id: '', page: 1, per_page: 10).each do |facade|
  facade.id
end
```

List only data requirements for forms.

```ruby
DocFox::DataRequirement::ListService.call(kyc_application_id: '', forms: true).map { _1 }
```

#### List data requirements associated with an account application

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Data-Requirements/paths/~1api~1v2~1account_applications~1%7Baccount_application_id%7D~1data_requirements/get

DocFox::DataRequirement::ListService.call(account_application_id: '', page: 1, per_page: 10).each do |facade|
  facade.id
end
```

List only data requirements for forms.

```ruby
DocFox::DataRequirement::ListService.call(account_application_id: '', forms: true).map { _1 }
```

#### Get a data requirement

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Data-Requirements/paths/~1api~1v2~1data_requirements~1%7Bdata_requirement_id%7D/get

service = DocFox::DataRequirement::GetService.call(id: '')
service.id
service.created_at
service.form
service.name
service.required
service.slug
service.valid_evidence_types
...
```

Include related resources.

`evidence_submissions`, `active_evidence_submission`, `active_evidence_submission.form`, `active_evidence_submission.form.active_form_datum`

```ruby
service = DocFox::DataRequirement::GetService.call(id: '', params: { include: 'evidence_submissions,active_evidence_submission' })
service.included
```

</details>

<details>
<summary>KYC Entity Templates</summary>

### KYC Entity Templates

#### List KYC entity templates

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/KYC-Entity-Templates/paths/~1api~1v2~1kyc_entity_templates/get

DocFox::KycEntityTemplate::ListService.call(page: 1, per_page: 10).each do |facade|
  facade.id
end
```

#### Get a KYC entity template

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/KYC-Entity-Templates/paths/~1api~1v2~1kyc_entity_templates~1%7Bkyc_entity_template_id%7D/get

service = DocFox::KycEntityTemplate::GetService.call(id: '')
service.id
service.kyc_entity_type_name
service.kyc_entity_type_category
service.created_at
service.profile_schema
...
```

</details>

<details>
<summary>Evidence Submissions</summary>

### Evidence Submissions

#### List evidence submissions

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Evidence-Submissions/paths/~1api~1v2~1data_requirements~1%7Bdata_requirement_id%7D~1evidence_submissions/get

DocFox::EvidenceSubmission::ListService.call(data_requirement_id: '', page: 1, per_page: 10).each do |facade|
  facade.id
end
```

#### Get an evidence submission

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Evidence-Submissions/paths/~1api~1v2~1evidence_submissions~1%7Bevidence_submission_id%7D/get

service = DocFox::EvidenceSubmission::GetService.call(id: '')
service.id
service.evidence_type
service.form
service.status
service.created_at
service.attributes
...
```

Include related resources.

`document`: the related document, for document evidence submission  
`qualitative_checks`: the related qualitative checks, for document evidence submission  
`rejection_reasons`: the related rejection reasons  
`form`: the related form, for form evidence submission  
`form.active_form_datum`: the related form and its latest data submission, for form evidence submission

```ruby
service = DocFox::EvidenceSubmission::GetService.call(id: '', params: { include: 'document,qualitative_checks' })
service.included
```

#### Update an evidence submission

At the moment this is used only to add third party data to an external evidence submission for a specific third party provider.

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Evidence-Submissions/paths/~1api~1v2~1evidence_submissions~1%7Bevidence_submission_id%7D/patch

DocFox::EvidenceSubmission::UpdateService.call(
  id: '',
  data: {
    type: 'evidence_submission',
    id: '',
    attributes: {
      results: {
        dob: '1984-01-01',
        gender: 'M',
        surname: 'Cartman',
        forename1: 'Eric',
        forename2: nil,
        id_number: '8401017223183',
        addresses: {
          address: [
            {
              addr_type: 'R',
              addr_line1: '28201 E. Bonanza St.',
              addr_line2: '',
              addr_line3: '',
              addr_line4: 'South Park',
              addr_postal_code: '8000',
              addr_update_date: '2017-11-21'
            }
          ]
        },
        telephones: {
          telephone: [
            {
              tel_num: '27715555555',
              tel_type: 'Cell',
              tel_update_date: '2017-09-05'
            }
          ]
        },
        deceased_date: nil,
        deceased_flag: 'N',
        verified_date: '2015-06-23',
        verified_flag: 'Y',
        deceased_reason: nil
      }
    }
  }
)
```

#### Reject an active evidence submission

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Evidence-Submissions/paths/~1api~1v2~1evidence_submissions~1%7Bevidence_submission_id%7D~1reject/patch

DocFox::EvidenceSubmission::RejectService.call(id: '', reason: '')
```

#### Approve an active evidence submission

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Evidence-Submissions/paths/~1api~1v2~1evidence_submissions~1%7Bevidence_submission_id%7D~1approve/patch

DocFox::EvidenceSubmission::ApproveService.call(id: '')
```

#### Replace an active evidence submission

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Evidence-Submissions/paths/~1api~1v2~1evidence_submissions~1%7Bevidence_submission_id%7D~1replace/patch

DocFox::EvidenceSubmission::ReplaceService.call(id: '')
```

</details>

<details>
<summary>Documents</summary>

### Documents

#### List documents

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Documents/paths/~1api~1v2~1evidence_submissions~1%7Bevidence_submission_id%7D~1documents/get

DocFox::Document::ListService.call(evidence_submission_id: '', page: 1, per_page: 10).each do |facade|
  facade.id
end
```

#### Get a document

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Documents/paths/~1api~1v2~1documents~1%7Bdocument_id%7D/get

service = DocFox::Document::GetService.call(id: '')
service.id
service.created_at
service.content_type
service.filename
service.token
service.token_expiry
service.uploaded_by
...
```

Include related resources.

`evidence_submissions`

```ruby
service = DocFox::Document::GetService.call(id: '', params: { include: 'evidence_submissions' })
service.included
```

</details>

<details>

<summary>Document Tokens</summary>

### Document Tokens

#### List document tokens

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Document-Tokens/paths/~1api~1v2~1documents~1%7Bdocument_id%7D~1document_tokens/get

DocFox::DocumentToken::ListService.call(document_id: '', page: 1, per_page: 10).each do |facade|
  facade.id
end
```

#### Get a document token

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Document-Tokens/paths/~1api~1v2~1document_tokens~1%7Bdocument_token_id%7D/get

service = DocFox::DocumentToken::GetService.call(id: '')
service.id
service.created_at
service.expiry
service.content_type
...
```

#### Create a document token

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Document-Tokens/paths/~1api~1v2~1documents~1%7Bdocument_id%7D~1document_tokens/post

DocFox::DocumentToken::CreateService.call(
  document_id: '',
  data: {
    type: 'document_token'
  }
)
```

</details>

<details>

<summary>Download Documents</summary>

### Download Documents

#### Download a document file

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Download-Documents/paths/~1api~1v2~1document_file_downloads~1%7Bdocument_token_id%7D/get

service = DocFox::Document::DownloadService.call(document_token_id: '', content_type: 'image/jpeg')
service.response.body # => "\xFF\xD8\xFF\xDB\x00\x84\x00\x04\x05\x..."
```

Possible values for `content_type`.

- `image/jpeg`
- `image/png`
- `application/pdf`

You can also provide just the `document_id` and the service will automatically request the `document_token_id` and `content_type` for you.

```ruby
service = DocFox::Document::DownloadService.call(document_id: '')
service.response.body # => "\xFF\xD8\xFF\xDB\x00\x84\x00\x04\x05\x..."
```

</details>

<details>

<summary>Document Uploads</summary>

### Document Uploads

#### Upload a document file

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Document-Uploads/paths/~1api~1v2~1evidence_submissions~1%7Bevidence_submission_id%7D~1documents/post

DocFox::Document::UploadService.call(
  evidence_submission_id: '',
  data: {
    type: 'document',
    attributes: {
      evidence_type: 'taxes_paid_in_prior_quarter',
      filename: 'taxes_paid.png',
      document_data: "data:image/png;base64,#{Base64.encode64(File.read('/path/to/taxes_paid.png'))}"
    }
  }
)
```
</details>

</details>

<details>
<summary>Users</summary>

### Users

#### List users

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Users/paths/~1api~1v2~1users/get

DocFox::User::ListService.call(page: 1, per_page: 10).each do |facade|
  facade.id
end
```

#### Get a user

```ruby
# https://www.docfoxapp.com/api/v2/documentation#tag/Users/paths/~1api~1v2~1users~1%7Buser_id%7D/get

service = DocFox::User::GetService.call(id: '')
service.id
service.email
service.first_names
service.last_names
service.deactivated
...
```

</details>

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kobusjoubert/doc_fox.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
