class MyHelperList < ActiveResource::Base
  include Taskassurable
  
  # alias is used for various labels and text strings to provide means for partner system to use different terminology for TaskAssure basic elements
  HELPER_ALIAS = ENV['HELPER_ALIAS'] || "Helper"

  belongs_to :buyer_user, :class_name => 'TaskassureUser'
  belongs_to :provider_user, :class_name => 'TaskassureUser'

end
