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
service = DocFox::KycApplication::ListService.call(page: 1, per_page: 10).each do |facade|
  facade.id
end
```

Filter by names, numbers contact information or external refs.

```ruby
DocFox::KycApplication::ListService.call(search_term: 'eric.cartman@example.com').map { _1 }
```

#### Get a KYC application

```ruby
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

```ruby
service = DocFox::KycApplication::GetService.call(id: '', params: { include: 'managed_by,profile.names' })
service.included
```

#### Create a KYC application

```ruby
service = DocFox::KycApplication::CreateService.call(
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
service = DocFox::KycApplication::ApproveService.call(id: '')
```

#### Unapprove a KYC application

```ruby
service = DocFox::KycApplication::UnapproveService.call(id: '', reason: '')
```

#### Transfer a KYC application

```ruby
service = DocFox::KycApplication::TransferService.call(id: '', transfer_to_user_id: '')
```

#### Archive a KYC application

```ruby
service = DocFox::KycApplication::ArchiveService.call(id: '', reason: '')
```

#### Unarchive a KYC application

```ruby
service = DocFox::KycApplication::UnarchiveService.call(id: '', reason: '')
```

#### Delete a KYC application

```ruby
service = DocFox::KycApplication::DeleteService.call(id: '')
```

</details>

<details>
<summary>KYC Entity Templates</summary>

### KYC Entity Templates

#### List KYC entity templates

```ruby
service = DocFox::KycEntityTemplate::ListService.call(page: 1, per_page: 10).each do |facade|
  facade.id
end
```

#### Get a KYC entity template

```ruby
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
<summary>Users</summary>

### Users

#### List users

```ruby
service = DocFox::User::ListService.call(page: 1, per_page: 10).each do |facade|
  facade.id
end
```

#### Get a user

```ruby
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
