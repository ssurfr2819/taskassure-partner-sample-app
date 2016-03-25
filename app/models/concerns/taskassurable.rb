require 'active_resource'

module Taskassurable
  extend ActiveSupport::Concern

  included do
	  cattr_accessor :static_headers
	  self.static_headers = headers
	  def self.headers
	    new_headers = static_headers.clone
	    new_headers["TA-API-KEY"] = ENV["TA-API-KEY"] || "test-partner-api-key"
	    new_headers["TA-API-SECRET"] = ENV["TA-API-SECRET"] || "test-partner-api-secret"
	    new_headers["TA-USER-TOKEN"] = Thread.current[:ta_user_token] if Thread.current[:ta_user_token] # voila, evaluated at request-time
	    new_headers
	  end

	  self.site = ENV["TASK_API_BASE"] || 'http://localhost:3000/api/v3'
	#  self.collection_parser = TaskCollection
	  self.format = :json
	  self.timeout = 5
	  add_response_method :ARes_response

  end

end
