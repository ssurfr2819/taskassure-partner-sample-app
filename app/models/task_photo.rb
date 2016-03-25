class TaskPhoto < ActiveResource::Base
  include Taskassurable

  belongs_to :task

end
