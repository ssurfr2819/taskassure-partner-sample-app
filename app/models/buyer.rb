class Buyer < ActiveResource::Base
  include Taskassurable

  belongs_to :user, :class_name => 'TaskassureUser'
  has_many :tasks
  
end
