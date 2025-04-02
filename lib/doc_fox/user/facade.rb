# frozen_string_literal: true

class DocFox::User::Facade
  attr_reader :id, :attributes, :deactivated, :deactivation_date, :email, :first_names, :last_names

  def initialize(hash)
    @id         = hash.dig('data', 'id') || hash['id']
    @attributes = hash.dig('data', 'attributes') || hash['attributes']

    @deactivated       = attributes['deactivated']
    @deactivation_date = attributes['deactivation_date']
    @email             = attributes['email']
    @first_names       = attributes['first_names']
    @last_names        = attributes['last_names']
  end
end
