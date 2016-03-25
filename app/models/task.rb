class Task < ActiveResource::Base
  include Taskassurable
  # alias is used for various labels and text strings to provide means for partner system to use different terminology for TaskAssure basic elements
  TASK_ALIAS = ENV['TASK_ALIAS'] || "Task"

  has_many :statuses
  has_many :task_photos
  #has_many :shares # not yet exposing these capabilities in API
  #has_many :notifications # not yet exposing these capabilities in API

  # use of a task category is up to the partner, it isn't required by TaskAssure 
  # if provided, category_id will be saved with the model as a 'has_one' association
  # due to technical constraints, the foreign key must be category_id (not a custom key)
  has_one :category

  belongs_to :provider
  belongs_to :buyer

  # status markers are pre-formatted strings to be used with Gmap mapping protocol
  # a null marker indicates a status was logged that did not include location
  def markers_string
	  mappoints = self.statuses.map {|s| {:created_at => s.created_at, :latitude => s.latitude, :marker => s.marker } }
	  mappoints.delete_if { |p| p[:marker].nil? }  # reject statuses with null marker strings
	  if mappoints.count > 0
	      markers_string = '[ '
	      mappoints.each do |point|
	          markers_string = markers_string + point[:marker] + ', '
	      end
	      markers_string = markers_string[0..markers_string.length - 3] + ' ]'
	  else
	      markers_string = nil
	  end
  end

end
