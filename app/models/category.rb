class Category < ActiveRecord::Base
	CATEGORIES = self.all
	OTHER = self.find_by_name("Other")
end
