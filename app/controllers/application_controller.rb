class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_current_user

  def authenticate_user!
  	@current_user = User.find_by_id(params[:user]) || current_user
  	session[:current_user_id] = @current_user.id
  end

  def set_current_user
  	if !session[:current_user_id].nil?
    	@current_user = User.find_by_id(session[:current_user_id])
    end
  end

def set_ta_user
  # using thread session store to hold user token for use in taskassurable objects
  logger.info "****** set ta user"
  Thread.current[:ta_user_token] = @current_user.ta_api_token if @current_user
end

end
