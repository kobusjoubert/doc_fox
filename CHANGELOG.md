## [0.2.1] - 2025-05-09

- README and Gemspec description updates.

## [0.2.0] - 2025-04-15

- DocFox::StatusSummary service objects
- DocFox::Profile service objects
- DocFox::DataRequirement service objects
- DocFox::EvidenceSubmission service objects
- DocFox::Document service objects
- README update with new added services
- Bug fix on DocFox::Authentication::GetService when no api_key

## [0.1.2] - 2025-04-05

- Set access token in before_call hook instead of lambda so we can capture errors from the access token service objects.
- Fixed empty list enumerable errors.

## [0.1.1] - 2025-04-02

- Fix `source_code_uri` and `changelog_uri` link in gemspec.

## [0.1.0] - 2025-04-02

- Initial release
- Intial `DocFox::KycApplication`, `DocFox::KycEntityTemplate` and `DocFox::User` service objects
