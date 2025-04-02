# frozen_string_literal: true

module DocFox::Enumerable
  extend ActiveSupport::Concern

  included do
    include Enumerable

    attr_reader :path, :facade_klass, :page, :per_page

    validates :path, :facade_klass, presence: true
    validates :page, :per_page, presence: true, numericality: { greater_than_or_equal_to: 1 }
  end

  def initialize(path:, facade_klass:, page: 1, per_page: Float::INFINITY)
    @path         = path
    @facade_klass = facade_klass
    @page         = page
    @per_page     = per_page
  end

  def call
    self
  end

  def each
    return to_enum(:each) unless block_given?
    return if invalid?

    total = 0

    catch :list_end do
      loop do
        @response = connection.get(path, params)
        validate(:response)

        unless success?
          raise exception_for(response, errors) if bang?

          throw :list_end
        end

        response.body['data'].each do |hash|
          yield facade_klass.new(hash)
          total += 1
          throw :list_end if total >= per_page
        end

        break if total >= response.body.dig('meta', 'total')

        @_params[:page] = response.body.dig('meta', 'page') + 1
      end
    end
  end

  private

  def params
    @_params ||= { page: page, per_page: max_per_page_per_request }
  end

  def max_per_page_per_request
    @_max_per_page_per_request ||= per_page.infinite? ? 100 : [per_page, 100].min
  end
end
