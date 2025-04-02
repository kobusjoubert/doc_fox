# frozen_string_literal: true

require 'active_call'
require 'active_call/api'
require 'active_support/core_ext/time'

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/active_call-doc_fox.rb")
loader.ignore("#{__dir__}/doc_fox/error.rb")
loader.collapse("#{__dir__}/doc_fox/concerns")
loader.setup

require_relative 'doc_fox/error'
require_relative 'doc_fox/version'

module DocFox; end
