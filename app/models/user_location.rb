class UserLocation < ActiveResource::Base
  include Taskassurable

  # alias is used for various labels and text strings to provide means for partner system to use different terminology for TaskAssure basic elements
  LOCATION_ALIAS = ENV['LOCATION_ALIAS'] || "Location"

  belongs_to :user

end
