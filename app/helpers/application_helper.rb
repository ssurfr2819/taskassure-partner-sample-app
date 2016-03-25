module ApplicationHelper

	#
	# Replaces all occurrences of 'txt' with corresponding label from env
	# Properly handles singular and plural forms of TaskAssure basic elements
	# For example, translates Locations to Properties if partner uses "Property"
	# Designed to help present flash messages in terminology of partner system
	#
	def replace_labels_using_env(txt)
		unless Task::TASK_ALIAS == "Task"
		  if txt =~ /task/i
		  	replace_txt = Task::TASK_ALIAS
			txt.gsub!(/\btasks\b/, replace_txt.pluralize.downcase)
			txt.gsub!(/\bTasks\b/, replace_txt.pluralize)
			txt.gsub!(/\btask\b/, replace_txt.downcase)
			txt.gsub!(/\bTask\b/, replace_txt)
		  end
		end
		unless UserLocation::LOCATION_ALIAS == "Location"
		  if txt =~ /location/i
		  	replace_txt = UserLocation::LOCATION_ALIAS
			txt.gsub!(/\blocations\b/, replace_txt.pluralize.downcase)
			txt.gsub!(/\bLocations\b/, replace_txt.pluralize)
			txt.gsub!(/\blocation\b/, replace_txt.downcase)
			txt.gsub!(/\bLocation\b/, replace_txt)
		  end
		end
		unless MyHelperList::HELPER_ALIAS == "Helper"
		  if txt =~ /helper/i
		  	replace_txt = MyHelperList::HELPER_ALIAS
			txt.gsub!(/\bhelpers\b/, replace_txt.pluralize.downcase)
			txt.gsub!(/\bHelpers\b/, replace_txt.pluralize)
			txt.gsub!(/\bhelper\b/, replace_txt.downcase)
			txt.gsub!(/\bHelper\b/, replace_txt)
		  end
		end
	  return txt
	end
end
