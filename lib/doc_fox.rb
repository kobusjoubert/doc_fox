# frozen_string_literal: true

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup

require_relative 'doc_fox/version'

module DocFox
  class Error < StandardError; end
end
