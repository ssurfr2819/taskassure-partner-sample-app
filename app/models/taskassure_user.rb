class TaskassureUser < ActiveResource::Base
  include Taskassurable
  self.element_name = "user"
  
  has_one :provider
  has_one :buyer

end
