class User < ActiveRecord::Base

attr_accessor :firstname, :lastname, :name, :email, :address, :city, :state, :zipcode, :country, :phone_number, :image_thumb_url# don't include this -- it blows up everything: , :ta_api_token

  has_one :provider
  has_one :buyer

  validates_uniqueness_of :email

end
