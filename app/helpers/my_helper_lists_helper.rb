module MyHelperListsHelper
	def get_data(user,type_value)
		case type_value 
		 when "name"
		  "#{user.firstname} #{user.lastname}"
		 when "pn"
		  "#{user.phone_number}"
		 when "ad"
          "#{user.address}"
		 when "ct"
          "#{user.city}"
		 when "st"
          "#{user.state}"
		 when "zp"
          "#{user.zipcode}"
		 when "co"
          "#{user.country}"
         end
	end
end
