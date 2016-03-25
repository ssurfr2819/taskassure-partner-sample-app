class WelcomeController < ApplicationController

def index
  begin
	  # get server host strings to show user
	  @host = ENV["TASK_API_BASE"] || "localhost:3000"
	  @localhost = request.host_with_port
	  @partner = Partner.find(:first, :from => :partner_self) # returns partner record if authenticated
	  @current_email = @current_user[:email] if @current_user
	  @users = User.all
  rescue ActiveResource::UnauthorizedAccess
    logger.info "****** rescue 0"
    flash[:error] = "Not authorized."
  rescue ActiveResource::TimeoutError
    logger.info "****** rescue 1"
    flash[:error] = "A network timeout occurred. Check your connectivity and try again."
  rescue ActiveResource::ResourceInvalid, ActiveResource::ResourceNotFound
    logger.info "****** rescue 2"
    flash[:error] = "Invalid operation."
  rescue => e
    logger.info "****** rescue 3"
    flash[:error] = "Unexpected problem: #{e}"
  end

end

end
