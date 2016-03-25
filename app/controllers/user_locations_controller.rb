class UserLocationsController < ApplicationController

  before_action :set_ta_user
  before_action :fetch_location, :except => [:index, :new, :create, :newpopup]

  def index
    begin
      user_locations = UserLocation.all(params: { page: params[:page] ||= 1, per_page: params[:per_page] ||= 10 })
    rescue ActiveResource::UnauthorizedAccess
      logger.info "****** rescue 0"
      flash[:error] = "Not authorized."
      redirect_to tasks_path and return
    rescue ActiveResource::TimeoutError
      logger.info "****** rescue 1"
      flash[:error] = "A network timeout occurred. Check your connectivity and try again."
      redirect_to tasks_path and return
    rescue ActiveResource::ResourceInvalid, ActiveResource::ResourceNotFound
      logger.info "****** rescue 2"
      flash[:error] = "Invalid operation."
      redirect_to tasks_path and return
    rescue => e
      logger.info "****** rescue 3"
      flash[:error] = "Unexpected problem: #{e}"
      redirect_to tasks_path and return
    else # remote call completed without raising error
      logger.info "****** locations: #{user_locations.inspect}"
      @user_locations = Kaminari::PaginatableArray.new(
      user_locations, 
      {
        :limit => user_locations.ARes_response['TA-array-limit'].to_i,
        :offset => user_locations.ARes_response['TA-array-offset'].to_i,
        :total_count => user_locations.ARes_response['TA-array-total'].to_i,
        :total_entries => user_locations.ARes_response['TA-array-total'].to_i
      })
    end
    # render index
  end

	def new
		begin
      @user_location = UserLocation.build
    rescue ActiveResource::UnauthorizedAccess
      logger.info "****** rescue 0"
      flash[:error] = "Not authorized."
      redirect_to user_locations_path and return
    rescue ActiveResource::TimeoutError
      logger.info "****** rescue 1"
      flash[:error] = "A network timeout occurred. Check your connectivity and try again."
      redirect_to user_locations_path and return
    rescue ActiveResource::ResourceInvalid, ActiveResource::ResourceNotFound
      logger.info "****** rescue 2"
      flash[:error] = "Invalid operation."
      redirect_to user_locations_path and return
    rescue => e
      logger.info "****** rescue 3"
      flash[:error] = "Unexpected problem: #{e}"
      redirect_to user_locations_path and return
    end
    # render new
	end

	def newpopup
    begin
      @user_location = UserLocation.build
    rescue => e
      logger.info "****** rescue from newpopup"
      flash[:error] = "Unexpected problem: #{e}"
    end
    # render new
	end

	def create
    if params[:commit] == "Save Location" # received from task form popup 'newpopup'
        logger.info "****** params from newpopup #{params.inspect}"
        @user_location = UserLocation.create(params[:user_location])
    else
  		begin
        @user_location = UserLocation.create(params[:user_location])
      rescue ActiveResource::UnauthorizedAccess
        logger.info "****** rescue 0"
        flash[:error] = "Not authorized."
        redirect_to user_locations_path and return
      rescue ActiveResource::TimeoutError
        logger.info "****** rescue 1"
        flash[:error] = "A network timeout occurred. Check your connectivity and try again."
        redirect_to user_locations_path and return
      rescue ActiveResource::ResourceInvalid, ActiveResource::ResourceNotFound
        logger.info "****** rescue 2"
        flash[:error] = "Invalid operation."
        redirect_to user_locations_path and return
      rescue => e
        logger.info "****** rescue 3"
        flash[:error] = "Unexpected problem: #{e}"
        redirect_to user_locations_path and return
      else # remote call completed without raising error, check results
        logger.info "****** checking remote response"
        if !@user_location.valid?
          # convert TaskAssure local time into our preferred format
          logger.info "****** location with errors: #{@user_location.inspect}"
          flash[:error] = "Please correct your errors:  #{@user_location.errors.full_messages}"
          render action: 'new' and return
        else
            flash[:notice] = "#{UserLocation::LOCATION_ALIAS} created successfully"
            redirect_to user_locations_path and return
        end
      end # rescue block
    end # create from standard user location form
	end

  def edit
    # before action sets up @user_location = UserLocation.find(params[:id])
    # format.html
  end

  def update
    # before action sets up @user_location = UserLocation.find(params[:id])
    begin
      @user_location.update_attributes(params[:user_location])
    rescue ActiveResource::UnauthorizedAccess
      logger.info "****** rescue 0"
      flash[:error] = "Not authorized."
      redirect_to user_locations_path and return
    rescue ActiveResource::TimeoutError
      logger.info "****** rescue 1"
      flash[:error] = "A network timeout occurred. Check your connectivity and try again."
      redirect_to user_locations_path and return
    rescue ActiveResource::ResourceInvalid
      logger.info "****** rescue 2a"
      flash[:error] = "Invalid operation."
      redirect_to user_locations_path and return
    rescue ActiveResource::ResourceNotFound
      logger.info "****** rescue 2b"
      flash[:error] = "#{UserLocation::LOCATION_ALIAS} does not exist"
      render action: 'edit' and return
    rescue => e
      logger.info "****** rescue 3"
      flash[:error] = "Unexpected problem: #{e}"
      redirect_to user_locations_path and return
    else # remote call completed without raising error, check results
      logger.info "****** checking remote response"
      if !@user_location.valid?
        # convert TaskAssure local time into our preferred format
        logger.info "****** location with errors: #{@user_location.inspect}"
        flash[:error] = "Please correct your errors:  #{@user_location.errors.full_messages}"
        render action: 'edit' and return
      else
        flash[:notice] = "#{UserLocation::LOCATION_ALIAS} updated successfully"
        redirect_to user_locations_path and return
      end
    end
  end

  def show
    # before action sets up @user_location = UserLocation.find(params[:id])
    # format.html
    logger.info "****** show location: #{@user_location.inspect}"
  end

	def destroy
		# before action sets up @user_location = UserLocation.find(params[:id])
		begin
      name = @user_location.name
      @user_location.destroy
      redirect_to user_locations_path, :notice => "#{UserLocation::LOCATION_ALIAS} '#{name}' deleted"
      return
    rescue ActiveResource::UnauthorizedAccess
      logger.info "****** rescue 0"
      flash[:error] = "Not authorized."
      redirect_to user_locations_path and return
    rescue ActiveResource::TimeoutError
      logger.info "****** rescue 1"
      flash[:error] = "A network timeout occurred. Check your connectivity and try again."
      redirect_to user_locations_path and return
    rescue ActiveResource::ResourceInvalid
      logger.info "****** rescue 2a"
      flash[:error] = "Invalid operation."
      redirect_to user_locations_path and return
    rescue ActiveResource::ResourceNotFound
      logger.info "****** rescue 2b"
      flash[:error] = "#{UserLocation::LOCATION_ALIAS} does not exist"
      redirect_to user_locations_path and return
    rescue => e
      logger.info "****** rescue 3"
      flash[:error] = "Unexpected problem: #{e}"
      redirect_to user_locations_path and return
		end
	end

private

def fetch_location
  begin
    @user_location = UserLocation.find(params[:id])
  rescue ActiveResource::UnauthorizedAccess
    logger.info "****** rescue 0"
    flash[:error] = "Not found or unauthorized."
    redirect_to user_locations_path and return
  rescue ActiveResource::TimeoutError
    logger.info "****** rescue 1"
    flash[:error] = "A network timeout occurred. Check your connectivity and try again."
    redirect_to user_locations_path and return
  rescue ActiveResource::ResourceInvalid => e
    logger.info "****** rescue 2a"
    flash[:error] = "Error during operation: #{e}"
    redirect_to user_locations_path and return
  rescue ActiveResource::ResourceNotFound => e
    logger.info "****** rescue 2b"
    flash[:error] = "Error during operation: Not found"
    redirect_to user_locations_path and return
  rescue => e
    logger.info "****** rescue 3"
    flash[:error] = "Unexpected problem: #{e}"
    redirect_to user_locations_path and return
  end
end

end
