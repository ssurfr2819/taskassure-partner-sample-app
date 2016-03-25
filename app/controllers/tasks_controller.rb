class TasksController < ApplicationController

  layout :resolve_layout

  before_action :set_ta_user
  before_action :fetch_task, :except => [:index, :new, :create, :display_my_locations, :get_helpers, :check_provider]
#  before_action :set_local_time_string, only: [:create, :update]

####################################
#
#  filter and other utility modules
#
####################################

 def adjust_for_dst(tz,task,old_task,increment)
  task.starts_at = task.starts_at.to_time + increment
  if tz.dst?(old_task.starts_at) == true    # determine if the original task iteration was dst
    if tz.dst?(task.starts_at) == false    # if first copy is not dst then need to add an hour
        task.starts_at = task.starts_at + 1.hours
    end
  else    # original task was not dst
    if tz.dst?(task.starts_at) == true    # if first copy is dst then need to subtract an hour
        task.starts_at = task.starts_at - 1.hours
    end
  end
  localtime = tz.time task.starts_at rescue nil
  task.local_time_string = localtime.strftime('%e %b %Y %l:%M %p')
end

def inc_condition(increment,tt)
  if tt.strip.downcase == "hours"
      return increment.hours
  elsif tt.strip.downcase == "days"
      return increment.days
  elsif tt.strip.downcase == "weeks"
      return increment.weeks
  else
      return increment.months
  end      
end

#
# JS functions
#

def get_helpers
  respond_to do |format|
    begin
      @providers = MyHelperList.find(:all, :from => :summary)
    rescue => e
      @errors = "Unexpected problem loading saved helpers: #{e}"
      format.js { render :action => 'get_helpers' }
    else
      format.js { render :action => 'get_helpers' }
    end #rescue
  end #respond
end

def display_my_locations
  respond_to do |format|
    begin
      @user_locations = UserLocation.find(:all, :from => :summary)
    rescue => e
      @errors = "Unexpected problem loading saved locations: #{e}"
      format.js { render :action => 'display_my_locations' }
    else
      format.js { render :action => 'display_my_locations' }
    end #rescue
  end #respond
end

def check_provider
  logger.info "****** checking provider"
  respond_to do |format|
    begin
      @email = params[:email].downcase.strip
      # api returns provider objects, including a provider_user object representing the user specific attributes
      @providers = Provider.all(:params => { :email => @email })
    rescue ActiveResource::ResourceNotFound
      logger.info "****** check provider resource not found"
      @provider = nil
      @result = "NoUser"
      format.js { render :action => 'provider_not_present' and return }
    rescue ActiveResource::ForbiddenAccess
      logger.info "****** check provider can't receive tasks"
      @provider = nil
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
        @provider = @providers.first
        logger.info "****** check provider provider: #{@provider.inspect}"
        format.js { render :action => 'check_provider' and return }
      end
    end
  end
end

#
# REST functions
#

def index
  logger.info "****** in index currentuser: #{@current_user}"
  respond_to do |format|
    begin
      tasks = Task.all(params: { page: params[:page] ||= 1, per_page: params[:per_page] ||= 10 })
    rescue ActiveResource::UnauthorizedAccess
      logger.info "****** rescue 0"
      format.html {
        flash[:error] = "Account not authorized."
        redirect_to root_path and return
      }
    rescue ActiveResource::TimeoutError
      logger.info "****** rescue 1"
      format.html {
        flash[:error] = "A network timeout occurred. Check your connectivity and try again."
        redirect_to root_path and return
      }
    rescue ActiveResource::ResourceInvalid
      logger.info "****** rescue 2"
      format.html {
        flash[:error] = "Unable to fetch #{Task::TASK_ALIAS.downcase.pluralize}."
        redirect_to root_path and return
      }
    rescue => e
      logger.info "****** rescue 3 in index"
      format.html {
        flash[:error] = "Unexpected problem: #{e}"
        redirect_to root_path and return
      }

    else # remote call completed without raising error
      logger.info "****** tasks: #{tasks.inspect}"
      format.html {
        @tasks = Kaminari::PaginatableArray.new(
        tasks,{
          :limit => tasks.ARes_response['TA-array-limit'].to_i,
          :offset => tasks.ARes_response['TA-array-offset'].to_i,
          :total_count => tasks.ARes_response['TA-array-total'].to_i,
          :total_entries => tasks.ARes_response['TA-array-total'].to_i
        })
        logger.info "ARes_response: #{tasks.ARes_response['TA-array-limit'].to_i}, #{tasks.ARes_response['TA-array-offset'].to_i}, #{tasks.ARes_response['TA-array-total'].to_i}"
        # using CATEGORIES constant in view @categories = Category.all
      }
    end
  end
end

def new
  respond_to do |format|
    begin
      @task = Task.build

    rescue ActiveResource::UnauthorizedAccess
      logger.info "****** rescue 0"
      format.html {
        flash[:error] = "Not authorized."
        redirect_to tasks_path and return
      }
    rescue ActiveResource::TimeoutError
      logger.info "****** rescue 1"
      format.html {
        flash[:error] = "A network timeout occurred. Check your connectivity and try again."
        redirect_to tasks_path and return
      }
    rescue ActiveResource::ResourceInvalid, ActiveResource::ResourceNotFound
      logger.info "****** rescue 2"
      format.html {
        flash[:error] = "Invalid operation."
        redirect_to tasks_path and return
      }
    rescue => e
      logger.info "****** rescue 3"
      format.html {
        flash[:error] = "Unexpected problem: #{e}"
        redirect_to tasks_path and return
      }

    else # remote call completed without raising error
      format.html {
        @task.local_time_string = preferred_strftime(@task.local_time_string) if @task.local_time_string
        logger.info "****** new task params: #{@task.inspect}"
      }
    end # rescue block
  end # respond to
end

def create
  respond_to do |format|
    # make sure the date is valid and convert to TaskAssure format e.g. '01 JAN 2016 08:00 AM' - required for partner API!!!
    unless params[:task][:local_time_string].blank?
      begin
        logger.info "****** create params: #{params.inspect}"
        add_params = {}
        # convert our preferred time to TaskAssure required format
        add_params = add_params.merge({"local_time_string" => TaskAssure_strftime(params[:task][:local_time_string])}) if params[:task][:local_time_string]
        # include default address and verification values in task params if checked by user
        add_params = add_params.merge({"default_address" => 1}) if params[:default_address]
        add_params = add_params.merge({"default_verification" => 1}) if params[:default_verification]
        logger.info "****** add_params: #{add_params}"
        @task = Task.create(params[:task].merge(add_params)) 
        logger.info "****** new task params: #{@task.inspect}"

      rescue ActiveResource::UnauthorizedAccess
        logger.info "****** rescue 0"
        flash[:error] = "Account not authorized."
        redirect_to root_path and return
      rescue ActiveResource::TimeoutError
        logger.info "****** rescue 1"
        @task = Task.build
        @task.load(params[:task]) # don't merge add_params on error
        logger.info "****** new task params: #{@task.inspect}"
        format.html {
          flash[:error] = "A network timeout occurred. Check your connectivity and try again."
          render action: 'new' and return
        }
      rescue ActiveResource::ResourceInvalid
        logger.info "****** rescue 2"
        @task = Task.build
        @task.load(params[:task]) # don't merge add_params on error
        logger.info "****** new task params: #{@task.inspect}"
        format.html {
          flash[:error] = "Check your entries and correct any errors."
          render action: 'new' and return
        }
      rescue => e
        logger.info "****** rescue 3"
        @task = Task.build
        @task.load(params[:task]) # don't merge add_params on error
        logger.info "****** new task params: #{@task.inspect}"
        format.html {
          flash[:error] = "Unexpected problem: #{e}"
          render action: 'new' and return
        }

      else # remote call completed without raising error, check results
        logger.info "****** checking remote response"
        # if !@task.valid?
        #   logger.info "****** task not valid from remote create"
        #   # create new task object for form, and load with our attributes (ARes.build doesn't seem to accept attributes directly)
        #   @task = Task.build
        #   @task.load(params[:task].merge(add_params))
        # end
        if !@task.valid?
          # convert TaskAssure local time into our preferred format
          @task.local_time_string = preferred_strftime(@task.local_time_string) if @task.local_time_string
          logger.info "****** task with errors: #{@task.inspect}"
          format.html {
            flash[:error] = "Please correct your errors:  #{@task.errors.full_messages}"
            render action: 'new' and return
          }
        else
          flash[:notice] = "#{Task::TASK_ALIAS} created successfully"
          redirect_to tasks_path and return
        end
      end # rescue block

    else # local time was blank - reject without remote call
      format.html {
        logger.info "****** local time string: #{params[:task][:local_time_string]}"
        @task = Task.build
        @task.load(params[:task])
        flash[:error] = "A valid Desired Start Time is required."
        render action: 'new' and return
      }
    end #blank localtime
  end #respond_to format

end

  # GET /api/v3/tasks/1/edit
def edit
  # before action sets up @task = Task.find(params[:id])
  respond_to do |format|
    #    params.merge(@task.attributes)
    format.html do
      # convert local time string to our preferred format
      @task.local_time_string = preferred_strftime(@task.local_time_string) if @task.local_time_string
      logger.debug "edit params: #{params.inspect}"    
      # @pl = current_account.subscription.photo_limit #no need for this iteration
      logger.debug "task: #{@task.inspect}  "
    #    provider = Provider.find(@task.provider_id)
      if @task.provider_id.nil? 
        flash[:alert] =  "This #{Task::TASK_ALIAS.downcase} has not been assigned to anyone."  
      else
    #      user = User.find_by_id(provider.user_id)
    #      @provider_email = user.email unless user.nil?
        
        # the following doesn't make sense, in that the line below it sets @provider = {:provider_email...
        # comment out for testing, then delete if confirmed no impact
        # @provider = MyHelperList.where("provider_user_id = ?",user.id).first
        
        # raise @provider.inspect
        # if @provider.nil?
    # don't think we need this=====>    @provider = {:provider_email => @provider_email}
        # end
        logger.debug "email: #{@provider_email}"
      end
    end # format.html
  end # respond to
end

def update
  #TODO refactor this into a module to share with create
  respond_to do |format|
    unless params[:task][:local_time_string].blank?
  # before action sets up @task = Task.find(params[:id])
      begin
        # make sure the date is valid and create an equivalent time string - required for partner API!!!
        logger.info "****** task id: #{@task.id}, old name: #{@task.name}, new name: #{params[:task][:name]}"
        add_params = {}
        # convert our preferred time to TaskAssure required format
        add_params = add_params.merge({"local_time_string" => TaskAssure_strftime(params[:task][:local_time_string])}) if params[:task][:local_time_string]
        # include default address and verification values in task params if checked by user
        add_params = add_params.merge({"default_address" => 1}) if params[:default_address]
        add_params = add_params.merge({"default_verification" => 1}) if params[:default_verification]
        logger.info "****** add_params: #{add_params}"
        @task.update_attributes(params[:task].merge(add_params)) 
        logger.info "****** new task params: #{@task.inspect}"

      rescue ActiveResource::UnauthorizedAccess
        logger.info "****** rescue 0"
        flash[:error] = "Account not authorized."
        redirect_to root_path and return
      rescue ActiveResource::TimeoutError
        logger.info "****** rescue 1"
        format.html {
          flash[:error] = "A network timeout occurred. Check your connectivity and try again."
          render action: 'edit' and return
        }
      rescue ActiveResource::ResourceInvalid
        logger.info "****** rescue 2"
        format.html {
          flash[:error] = "Check your entries and correct any errors."
          render action: 'edit' and return
        }
      rescue => e
        logger.info "****** rescue 3"
        format.html {
          flash[:error] = "Unexpected problem: #{e}"
          render action: 'edit' and return
        }

      else # remote call completed, check results
        logger.info "****** check remote response"
        if !@task.valid?
          format.html {
            flash[:error] = "Please correct your errors:  #{@task.errors.full_messages}"
            render action: 'edit' and return
          }
        else
          flash[:notice] = "#{Task::TASK_ALIAS} updated successfully"
          redirect_to tasks_path and return
        end
      end # rescue block
    else # local time was blank - reject without remote call
      format.html {
        logger.info "****** local time string: #{params[:task][:local_time_string]}"
        flash[:error] = "A valid Desired Start Time is required."
        render action: 'edit' and return
      }
    end #blank localtime
  end #respond_to format
end

def show
  respond_to do |format|
  # before action sets up @task = Task.find(params[:id])
    format.html do
      # when caching statuses for task, only need to use count as an expiration trigger, since statuses are not updated
      # @statuses = @task.statuses.find(:all, :order => "created_at DESC")
      # use ASC order for mappoints so that duplicates show the latest one
      #@json2 = Rails.cache.fetch("/statuses/markers/v2/#{@task.id}-#{@task.statuses.count}", :expires_in => 30.days) do
      @json2 = @task.markers_string
      #end
      #raise "#{@actions_before} === #{@actions_after}"
  #logger.info "** JSON2: #{@json2}"
  #logger.info "** LocationCount: #{@location_count}"
      @title = "#{Task::TASK_ALIAS} Show"
      @task.local_time_string = preferred_strftime(@task.local_time_string) if @task.local_time_string
    end # format.html
  end # respond do
end

def map1
  # before action sets up @task = Task.find(params[:id])
  # use ASC order for mappoints so that duplicates show the latest one
  #@json2 = Rails.cache.fetch("/statuses/markers/v2/#{@task.id}-#{@task.statuses.count}", :expires_in => 30.days) do
  @json2 = @task.markers_string

  #end
end

def copy
  # before action sets up @task = Task.find(params[:id])
  @old_task = @task  #Task.find(params[:id])
  unless (@task.valid_task) && (@task.provider_id)
    redirect_to tasks_path, :alert => "Only #{Task::TASK_ALIAS.downcase.pluralize} that have an address and assigned #{MyHelperList::HELPER_ALIAS.downcase} can be copied"
    return
  else
    logger.info "******* copyaction: params['copyaction']"
    if request.post? && params["copyaction"] == "cancel"
      redirect_to tasks_path, :notice => "Copy operation cancelled"
      return
    end
    if request.post? && params["copyaction"] == "copy"
      @aborted = false
      tk = 1
      temp = 0
      number = params["number"].to_i
      if number > 4  # for current release limit to 4
        number = 4 
        @aborted = true
      end
      increment = params["increment"].to_i
      tt  =  params["timetype"]
      increment_tt =  inc_condition(increment,tt)
      tz = Timezone::Zone.new :zone => @old_task.zone 
      count = 0
      timeout_count = 0
      (tk..number).each do |i|
        begin
          if count == 0
            task = Task.new(@old_task.attributes)
            adjust_for_dst(tz,task,@old_task,increment_tt)
          else
            task = Task.new(temp.attributes)
            adjust_for_dst(tz,task,temp,increment_tt)
          end
          task.buyer_id = @old_task.buyer_id
          task.provider_id = @old_task.provider_id
          task.time_on_task = 0  # clear time on task attribute on task copies
          #unless task.check_task_limit(current_user)
          task.save
            # if task.email_notifications_status_changes == true
            #   task.email_notifications_verification_alerts = true
            # else
            #   task.email_notifications_verification_alerts = false
            # end
            # if task.text_message_status_changes == true
            #   task.update_column(:text_message_verification_alerts, true)
            # else
            #   task.update_column(:text_message_verification_alerts, false)
            # end
            # @notification = Notification.new(:email_notifications_status_changes => task.email_notifications_status_changes,:email_notifications_verification_alerts=> task.email_notifications_verification_alerts,:text_message_status_changes => task.text_message_status_changes,:text_message_verification_alerts => task.text_message_verification_alerts,:user_id => current_user.id,:task_id =>task.id,:buyer_id =>task.buyer_id)
            # @notification.save
          temp = Task.find(task.id)
          count += 1
          #else
            #@aborted = true # we don't abort the loop, since might create additional copies in other months
          #end #unless end
        rescue ActiveResource::TimeoutError
          logger.info "****** rescue 1"
          timeout_count += 1
          if timeout_count <= 3
            logger.info "****** continuing from timeout #{timeout_count}"
            next
          else
              flash[:error] = "The network or system is experiencing problems with your request at this time."
              redirect_to tasks_path and return
          end
        rescue ActiveResource::ResourceInvalid, ActiveResource::ResourceNotFound
          logger.info "****** rescue 2"
            flash[:error] = "An unrecoverable system error occurred. One or all of your copies was unsuccessful."
            redirect_to tasks_path and return
        rescue => e
          logger.info "****** rescue 3"
            flash[:error] = "Unexpected problem: #{e}"
            redirect_to tasks_path and return
        end #begin-rescue block
      end #loop end
      if @aborted
        redirect_to tasks_path, :alert => "#{count} #{Task::TASK_ALIAS.downcase.pluralize} created on #{params["number"]} requested due to system limit " and return
      else
        redirect_to tasks_path, :notice => "#{count} #{Task::TASK_ALIAS.downcase} copies created successfully" and return
      end#abort end
    end #copy action
  end #redirect unless valid, otherwise render copy form
end #def end

def delete_task
  # before action sets up @task = Task.find(params[:id])
  if params[:commit] == "Cancel"
    # if self.class.name.split("::").first=="M"
    #   render :text => "<h3 style='padding-top:40px; color:#0d8484;'>Delete cancelled</h3>"
    # end
    redirect_to tasks_path, :notice => "Delete operation cancelled"
    return
  end
  
  if request.delete?
    begin
      name = @task.name
      buyer_id = @task.buyer_id
      if params["delete"] == "all"
        @task.destroy
        tasks = Task.find(:all, :params => { :name => @task.name })
        tasks.each do |t|
          begin
            logger.info "****** would delete task #{t.id}"
            t.destroy
          rescue ActiveResource::ResourceNotFound
            logger.info "****** rescue task not found during delete all"
            next
          end
        end
        redirect_to tasks_path, :notice => "A total '#{tasks.count + 1}' #{Task::TASK_ALIAS.downcase.pluralize} named '#{name}' were deleted"
        return
      else
        @task.destroy
        redirect_to tasks_path, :notice => "#{Task::TASK_ALIAS} '#{name}' deleted"
        return
      end
    rescue ActiveResource::UnauthorizedAccess
      logger.info "****** rescue 0"
      flash[:error] = "#{Task::TASK_ALIAS} not found or not authorized for delete."
      redirect_to tasks_path and return
    rescue ActiveResource::TimeoutError
      logger.info "****** rescue 1"
      flash[:error] = "A network timeout occurred. Check your connectivity and try again."
      redirect_to tasks_path and return
    rescue ActiveResource::ResourceNotFound
      logger.info "****** rescue 2b"
      flash[:error] = "A #{Task::TASK_ALIAS.downcase} you wanted to delete does not exist."
      redirect_to tasks_path and return
    rescue ActiveResource::ResourceInvalid
      logger.info "****** rescue 2a"
      flash[:error] = "An error occurred during the delete process."
      redirect_to tasks_path and return
    rescue => e
      logger.info "****** rescue 3"
      flash[:error] = "Unexpected problem: #{e}"
      redirect_to tasks_path and return
    end #rescue block
  end #delete action
end

private

def fetch_task
  begin
    @task = Task.find(params[:id])
  rescue ActiveResource::UnauthorizedAccess
    logger.info "****** rescue 0"
    flash[:error] = "#{Task::TASK_ALIAS} not found or unauthorized."
    redirect_to tasks_path and return
  rescue ActiveResource::TimeoutError
    logger.info "****** rescue 1"
    flash[:error] = "A network timeout occurred. Check your connectivity and try again."
    redirect_to tasks_path and return
  rescue ActiveResource::ResourceInvalid => e
    logger.info "****** rescue 2a"
    flash[:error] = "Error during operation: #{e}"
    redirect_to tasks_path and return
  rescue ActiveResource::ResourceNotFound => e
    logger.info "****** rescue 2b"
    flash[:error] = "Error during operation: Not found"
    redirect_to tasks_path and return
  rescue => e
    logger.info "****** rescue 3 in fetch"
    flash[:error] = "Unexpected problem: #{e}"
    redirect_to tasks_path and return
  end
end

def resolve_layout
  case action_name
  when "map1"
     "map"
  else
     "application"
  end
end

  def preferred_strftime(time_string, preferred_format='%m/%d/%Y %I:%M %p')
    if time_string
      dt = DateTime.strptime(time_string, "%e %b %Y %l:%M %p")
      new_time_string = dt.strftime(preferred_format) 
    end
  end

  def TaskAssure_strftime(time_string, preferred_format='%m/%d/%Y %I:%M %p')
    if time_string
      dt = DateTime.strptime(time_string, preferred_format)
      new_time_string = dt.strftime("%e %b %Y %l:%M %p") 
    end
  end

end
