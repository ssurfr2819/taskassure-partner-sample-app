class PartnersController < ApplicationController

  #
  # new partners are created on the TaskAssure base route only
  #

  #
  # partners/edit
  #
  def edit
    @partner = Partner.find(params[:id])
  end

  def update
    @partner = Partner.find(params[:id])
    begin
      @partner.update_attributes(params[:partner])
    rescue ActiveResource::UnauthorizedAccess
      logger.info "****** rescue 0"
      flash[:error] = "Not authorized."
      redirect_to root_path and return
    rescue ActiveResource::TimeoutError
      logger.info "****** rescue 1"
      flash[:error] = "A network timeout occurred. Check your connectivity and try again."
      render action: 'edit' and return
    rescue ActiveResource::ResourceInvalid
      logger.info "****** rescue 2a"
      flash[:error] = "Invalid operation."
      render action: 'edit' and return
    rescue ActiveResource::ResourceNotFound
      logger.info "****** rescue 2b"
      flash[:error] = "Partner does not exist"
      render action: 'edit' and return
    rescue => e
      logger.info "****** rescue 3"
      flash[:error] = "Unexpected problem: #{e}"
      render action: 'edit' and return
    else # remote call completed without raising error, check results
      logger.info "****** checking remote response"
      if !@partner.valid?
        # convert TaskAssure local time into our preferred format
        logger.info "****** partner with errors: #{@partner.inspect}"
        flash[:error] = "Please correct your errors:  #{@partner.errors.full_messages}"
        render action: 'edit' and return
      else
        flash[:notice] = "Partner updated successfully"
        redirect_to root_path and return
      end
    end
  end

  def show
    @partner = Partner.find(params[:id])
    logger.info "****** show partner: #{@partner.inspect}"
  end

private


end
