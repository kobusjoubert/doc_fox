# frozen_string_literal: true

class DocFox::Authentication::Facade
  attr_reader :nonce, :digest_algorithm

  def initialize(hash)
    attributes = hash.dig('data', 'attributes')

    @nonce            = attributes['nonce']
    @digest_algorithm = attributes['digest_algorithm']
  end
end
