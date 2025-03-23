# frozen_string_literal: true

require 'active_call'
require 'faraday'
require 'faraday/retry'
require 'faraday/logging/color_formatter'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/doc_fox/error.rb")
loader.collapse("#{__dir__}/doc_fox/concerns")
loader.setup

require_relative 'doc_fox/error'
require_relative 'doc_fox/version'

module DocFox; end

ActiveSupport.on_load(:i18n) do
  I18n.load_path << File.expand_path('doc_fox/locale/en.yml', __dir__)
end
