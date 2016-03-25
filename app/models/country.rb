class Country < ActiveRecord::Base
	COUNTRIES = self.all
	US = self.find_by_iso("US")
end
