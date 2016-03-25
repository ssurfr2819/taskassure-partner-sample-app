class TaskassureUsersController < ApplicationController
  before_action :set_ta_user, only: [:new_helper, :create_helper]

  def index
  end

  def new
  end

  def create
    logger.info "in taskassure_user controller create"
    @taskassure_user = TaskassureUser.create(user_params)
  end

  def new_helper
    begin
      @taskassure_user = TaskassureUser.build # GET /api/v3/users/new (taskassure_user translates to user)
      logger.info "****** TaskassureUser from build: #{@taskassure_user.inspect}"
    rescue ActiveResource::UnauthorizedAccess
      flash[:error] = "Not authorized."
      render action: 'new_helper' and return
    rescue ActiveResource::TimeoutError
      flash[:error] = "A network timeout occurred. Check your connectivity and try again."
      render action: 'new_helper' and return
    rescue => e
      logger.info "****** new helper exception: #{e}"
      flash[:error] = "Unexpected problem: #{e}"
      render action: 'new_helper' and return
    end
  end

  def create_helper
    begin
      logger.info "****** create helper params: #{params[:taskassure_user]}"
      @taskassure_user = TaskassureUser.post(:create_helper, nil, params[:taskassure_user].to_json)
    rescue ActiveResource::UnauthorizedAccess
      @taskassure_user = TaskassureUser.build
      flash[:error] = "Not authorized."
      render :action => 'new_helper' and return
    rescue ActiveResource::TimeoutError
      @taskassure_user = TaskassureUser.build
      flash[:error] = "A network timeout occurred. Check your connectivity and try again."
      render :action => 'new_helper' and return
    rescue => e
      logger.info "****** create helper exception: #{e}"
      @create_success = false
      @taskassure_user = TaskassureUser.build
      flash[:error] = "Unexpected problem: #{e}"
      render :action => 'new_helper' and return
    else
      #@taskassure_user = TaskassureUser.find(???)
      logger.info "****** new tauser: #{@taskassure_user.inspect}"
      # now create a local one?
      @create_success = true
    end
  end

	def user_params
	  params.permit(:email, :firstname, :lastname, :ta_api_token)
	end

end
