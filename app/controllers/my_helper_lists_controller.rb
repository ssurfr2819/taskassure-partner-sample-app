class MyHelperListsController < ApplicationController

  before_action :set_ta_user
  before_action :fetch_helper, :except => [:index, :new, :create, :newpopup, :check_helper]


#
# JSON entries
#
# TODO use concern for my_helper_lists#check_helper and tasks#check_provider
def check_helper
  logger.info "****** checking provider"
  respond_to do |format|
    begin
      @email = params[:email].downcase.strip
      # api returns provider objects, including a provider_user object representing the user specific attributes
      @providers = Provider.all(:params => { :email => @email })
    rescue ActiveResource::ResourceNotFound
      logger.info "****** check provider resource not found"
      @provider_user = nil
      @result = "NoUser"
      format.js { render :action => 'provider_not_present' and return }
    rescue ActiveResource::ForbiddenAccess
      logger.info "****** check provider can't receive tasks"
      @provider_user = nil
      @result = "InvalidUser"
      format.js { render :action => 'provider_not_present' and return }
    rescue => e
      logger.info "****** check provider providers: #{@providers.inspect}"
      logger.info "****** check provider unexpected problem: #{e}"
      @errors = "Unexpected problem checking helper: #{e}"
      format.js { render :action => 'provider_not_present' and return }
    else
      logger.info "****** check provider providers: #{@providers.inspect}"
      if !@providers
        @result = "NoUser"
        logger.info "****** no providers "
        format.js { render :action => 'provider_not_present' and return }
      else
        @provider_user = @providers.first.provider_user
        logger.info "****** check provider provider: #{@provider_user.inspect}"
        format.js { render :action => 'provider_desc' and return }
      end
    end
  end
end

#
# REST entries
#
  def index
    begin
      my_helper_lists = MyHelperList.all(params: { page: params[:page] ||= 1, per_page: params[:per_page] ||= 10 })
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
      logger.info "****** helper lists: #{my_helper_lists.inspect}"
      flash[:error] = "Unexpected problem: #{e}"
      redirect_to tasks_path and return
    else # remote call completed without raising error
      logger.info "****** helper lists: #{my_helper_lists.inspect}"
      @my_helper_lists = Kaminari::PaginatableArray.new(
      my_helper_lists, 
      {
        :limit => my_helper_lists.ARes_response['TA-array-limit'].to_i,
        :offset => my_helper_lists.ARes_response['TA-array-offset'].to_i,
        :total_count => my_helper_lists.ARes_response['TA-array-total'].to_i,
        :total_entries => my_helper_lists.ARes_response['TA-array-total'].to_i
      })
    end
    # render index
  end

	def new
		begin
      @my_helper_list = MyHelperList.build
    rescue ActiveResource::UnauthorizedAccess
      logger.info "****** rescue 0"
      flash[:error] = "Not authorized."
      redirect_to my_helper_lists_path and return
    rescue ActiveResource::TimeoutError
      logger.info "****** rescue 1"
      flash[:error] = "A network timeout occurred. Check your connectivity and try again."
      redirect_to my_helper_lists_path and return
    rescue ActiveResource::ResourceInvalid, ActiveResource::ResourceNotFound
      logger.info "****** rescue 2"
      flash[:error] = "Invalid operation."
      redirect_to my_helper_lists_path and return
    rescue => e
      logger.info "****** rescue 3"
      flash[:error] = "Unexpected problem: #{e}"
      redirect_to my_helper_lists_path and return
    end
    # render new
	end

	def newpopup
    begin
      @my_helper_list = MyHelperList.build
    rescue => e
      logger.info "****** rescue from newpopup"
      flash[:error] = "Unexpected problem: #{e}"
    end
    # render new
	end

	def create
    if params[:commit] == "Create Helper" # received from create helper popup taskassure_users#new_helper
        logger.info "****** params from newpopup #{params.inspect}"
        @my_helper_list = MyHelperList.create(params[:my_helper_list])
    else
  		begin
        @my_helper_list = MyHelperList.create(params[:my_helper_list])
      rescue ActiveResource::UnauthorizedAccess
        logger.info "****** rescue 0"
        flash[:error] = "Not authorized."
        redirect_to my_helper_lists_path and return
      rescue ActiveResource::TimeoutError
        logger.info "****** rescue 1"
        flash[:error] = "A network timeout occurred. Check your connectivity and try again."
        redirect_to my_helper_lists_path and return
      rescue ActiveResource::ResourceInvalid, ActiveResource::ResourceNotFound
        logger.info "****** rescue 2"
        flash[:error] = "Invalid operation."
        redirect_to my_helper_lists_path and return
      rescue => e
        logger.info "****** rescue 3"
        flash[:error] = "Unexpected problem: #{e}"
        redirect_to my_helper_lists_path and return
      else # remote call completed without raising error, check results
        logger.info "****** checking remote response"
        if !@my_helper_list.valid?
          # convert TaskAssure local time into our preferred format
          logger.info "****** helper list with errors: #{@my_helper_list.inspect}"
          flash[:error] = "Please correct your errors:  #{@my_helper_list.errors.full_messages}"
          render action: 'new' and return
        else
          flash[:notice] = "#{MyHelperList::HELPER_ALIAS} '#{params[:provider_email]}' created successfully"
          redirect_to my_helper_lists_path and return
        end
      end # rescue block
    end # create from standard user helper form
	end

  def edit
    # before action sets up @my_helper_list = MyHelperList.find(params[:id])
    # format.html
    logger.info "****** myhelperlist edit: #{@my_helper_list.inspect}"
  end

  def update
    # before action sets up @my_helper_list = MyHelperList.find(params[:id])
    begin
      @my_helper_list.update_attributes(params[:my_helper_list])
    rescue ActiveResource::UnauthorizedAccess
      logger.info "****** rescue 0"
      flash[:error] = "Not authorized."
      redirect_to my_helper_lists_path and return
    rescue ActiveResource::TimeoutError
      logger.info "****** rescue 1"
      flash[:error] = "A network timeout occurred. Check your connectivity and try again."
      redirect_to my_helper_lists_path and return
    rescue ActiveResource::ResourceInvalid
      logger.info "****** rescue 2a"
      flash[:error] = "Invalid operation."
      redirect_to my_helper_lists_path and return
    rescue ActiveResource::ResourceNotFound
      logger.info "****** rescue 2b"
      flash[:error] = "#{MyHelperList::HELPER_ALIAS} does not exist"
      render action: 'edit' and return
    rescue => e
      logger.info "****** rescue 3"
      flash[:error] = "Unexpected problem: #{e}"
      redirect_to my_helper_lists_path and return
    else # remote call completed without raising error, check results
      logger.info "****** checking remote response"
      if !@my_helper_list.valid?
        # convert TaskAssure local time into our preferred format
        logger.info "****** helper list with errors: #{@my_helper_list.inspect}"
        flash[:error] = "Please correct your errors:  #{@my_helper_list.errors.full_messages}"
        render action: 'edit' and return
      else
        flash[:notice] = "#{MyHelperList::HELPER_ALIAS} updated successfully"
        redirect_to my_helper_lists_path and return
      end
    end
  end

  def show
    # before action sets up @my_helper_list = MyHelperList.find(params[:id])
    # format.html
    logger.info "****** show helper: #{@my_helper_list.inspect}"
  end

	def destroy
		# before action sets up @my_helper_list = MyHelperList.find(params[:id])
		begin
      @my_helper_list.destroy
      redirect_to my_helper_lists_path, :notice => "#{MyHelperList::HELPER_ALIAS} deleted"
      return
    rescue ActiveResource::UnauthorizedAccess
      logger.info "****** rescue 0"
      flash[:error] = "Not authorized."
      redirect_to my_helper_lists_path and return
    rescue ActiveResource::TimeoutError
      logger.info "****** rescue 1"
      flash[:error] = "A network timeout occurred. Check your connectivity and try again."
      redirect_to my_helper_lists_path and return
    rescue ActiveResource::ResourceInvalid
      logger.info "****** rescue 2a"
      flash[:error] = "Invalid operation."
      redirect_to my_helper_lists_path and return
    rescue ActiveResource::ResourceNotFound
      logger.info "****** rescue 2b"
      flash[:error] = "#{MyHelperList::HELPER_ALIAS} does not exist"
      redirect_to my_helper_lists_path and return
    rescue => e
      logger.info "****** rescue 3"
      flash[:error] = "Unexpected problem: #{e}"
      redirect_to my_helper_lists_path and return
		end
	end

private

def fetch_helper
  begin
    @my_helper_list = MyHelperList.find(params[:id])
  rescue ActiveResource::UnauthorizedAccess
    logger.info "****** rescue 0"
    flash[:error] = "Not found or unauthorized."
    redirect_to my_helper_lists_path and return
  rescue ActiveResource::TimeoutError
    logger.info "****** rescue 1"
    flash[:error] = "A network timeout occurred. Check your connectivity and try again."
    redirect_to my_helper_lists_path and return
  rescue ActiveResource::ResourceInvalid => e
    logger.info "****** rescue 2a"
    flash[:error] = "Error during operation: #{e}"
    redirect_to my_helper_lists_path and return
  rescue ActiveResource::ResourceNotFound => e
    logger.info "****** rescue 2b"
    flash[:error] = "Error during operation: Not found"
    redirect_to my_helper_lists_path and return
  rescue => e
    logger.info "****** rescue 3"
    flash[:error] = "Unexpected problem: #{e}"
    redirect_to my_helper_lists_path and return
  end
end

end
