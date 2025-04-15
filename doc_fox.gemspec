# frozen_string_literal: true

require_relative 'lib/doc_fox/version'

Gem::Specification.new do |spec|
  spec.name = 'active_call-doc_fox'
  spec.version = DocFox::VERSION
  spec.authors = ['Kobus Joubert']
  spec.email = ['kobus@translate3d.com']

  spec.summary = 'DocFox'
  spec.description = 'DocFox exposes the nCino KYC DocFox API endpoints through service objects.'
  spec.homepage = 'https://github.com/kobusjoubert/doc_fox'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/kobusjoubert/doc_fox'
  spec.metadata['changelog_uri'] = 'https://github.com/kobusjoubert/doc_fox/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'active_call-api', '~> 0.1'
  spec.add_dependency 'faraday-follow_redirects', '~> 0.3'
  spec.add_dependency 'openssl', '~> 3.3'
end
