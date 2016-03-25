class UsersController < ApplicationController

  def index
  end

  def new
    @user = User.new
    @user.role = "buyer"
  end

  def create
    #begin
    @user = User.create(user_params)
    if @user.valid?
      # for unknown reason, the create method is not setting email, first and last name
      # probably due to use of strong params .... need to explore
      @user.update_column(:email, user_params[:email])
      @user.update_column(:firstname, user_params[:firstname])
      @user.update_column(:lastname, user_params[:lastname])
      ta_params = { "email" => @user.email, "firstname" => @user.firstname, "lastname" => @user.lastname, "role" => @user.role }
      logger.info "****** TaskAssure params: #{ta_params}"
      @taskassure_user = TaskassureUser.create(ta_params)
      logger.info "****** new taskassure user: #{@taskassure_user.inspect}"
      # @taskassure_user.save
      if !@taskassure_user.valid?
        @user.delete  # undo new user if can't create taskassure user
        logger.info "****** task with errors: #{@task.inspect}"
        flash[:error] = "Please correct your errors:  #{@taskassure_user.errors.full_messages}"
        render action: 'new' and return
      else
        @user.update_column(:ta_api_token, @taskassure_user.ta_api_token)
        session[:current_user_id] = @user.id
        @current_user = @user
        flash[:notice] = "User created successfully"
        redirect_to tasks_path and return
      end
    else
      logger.info "****** user with errors: #{@user.inspect}"
      flash[:error] = "Please correct your errors:  #{@user.errors.full_messages}"
      render action: 'new' and return
    end
      # rescue Exception => e
      #   logger.info "****** error in create: #{e.inspect}"  
      # end

  end

  def switch
  	logger.info "****** switch params #{params.inspect}"
    @user = User.find_by_id(switch_params[:id])  || current_user
#  	@user.ta_api_token = user_params[:ta_api_token]
  	if @user.present?
	  	session[:current_user_id] = @user.id
	  	@current_user = @user
	  	#@user.ta_api_token = @user.first.ta_api_token
	  	#authenticate_user! # switch to user in the params
	  	redirect_to tasks_path
	   else
        flash[:error] = "Invalid user selected"
        redirect_to root_path
    end
  end

  private

	def user_params
	  params.require(:user).permit(:email, :firstname, :lastname, :role, :ta_api_token)
	end

  def switch_params
    params.permit(:id)
  end

end
