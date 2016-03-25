class PaginatedCollection < ActiveResource::Collection

  # Our custom array to handle pagination methods
  attr_accessor :paginatable_array

  # The initialize method will receive the ActiveResource parsed result
  # and set @elements.
  def initialize(elements = [])
puts "********* connection: #{ActiveResource::Collection.connection.inspect}"
    @elements = elements
    setup_paginatable_array
  end

  # Retrieve response headers and instantiate a paginatable array
  def setup_paginatable_array
puts "********* paginatable array ********"
    @paginatable_array ||= begin
      response = ActiveResource::Base.connection.response #rescue {}
puts "********* response #{response}"
      options = {
        limit: 10, #response["Pagination-Limit"].try(:to_i),
        offset: 0, #response["Pagination-Offset"].try(:to_i),
        total_count: 54, #response["Pagination-TotalCount"].try(:to_i),
        num_pages: 6 #response["Pagination-TotalPages"].try(:to_i)
      }
puts "*********  options #{options}"
      Kaminari::PaginatableArray.new(elements, options)
    end
  end

  private

  # Delegate missing methods to our `paginatable_array` first,
  # Kaminari might know how to respond to them
  # E.g. current_page, total_count, etc.
  def method_missing(method, *args, &block)
    if paginatable_array.respond_to?(method)
puts "****** method missing check: #{method}, #{args}, #{block} ********"
      paginatable_array.send(method)
    else
puts "****** no method missing *******"
      super
    end
  end
end
