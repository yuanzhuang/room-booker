class ErrorHandlerController < ApplicationController

  # 0,1,2,3
  VALIDATION_ERROR = ["USERNAME","INVITEES","DATE and TIME","DATE","TIME"]

  # booking conflict checked
  def conflict
    booking_id = params[:id]
    @conflict_booking = Booking.find(booking_id)
    @user_info = User.find(@conflict_booking.user_id)

    respond_to do |format|
      format.html
      format.json {render :xml=>@conflict_booking}
    end
  end

  def validation
    @error_string = ErrorHandlerController::VALIDATION_ERROR[params[:id].to_i]
    respond_to do |format|
      format.html
      format.json {render :xml=>@error_string}
    end
  end

  def others

  end

end
