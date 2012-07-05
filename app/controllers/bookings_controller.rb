
class BookingsController < ApplicationController
  # GET /bookings
  # GET /bookings.json
  def index
    @bookings = Booking.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bookings }
    end
  end

  # GET /bookings/1
  # GET /bookings/1.json
  def show
    @booking = Booking.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @booking }
    end
  end

  # GET /bookings/new
  # GET /bookings/new.json
  def new
    @booking = Booking.new
    @room = Room.find(params[:roomid])
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @booking }
    end
  end

  # GET /bookings/1/edit
  def edit
    @booking = Booking.find(params[:id])
  end

  # POST /bookings
  # POST /bookings.json
  def create
    @booking_userid = User.find_by_username(params[:username])
    @guid = params[:username]
    @booking = Booking.new()
    @booking.user_id= @booking_userid
    @room = Room.find_by_name(params[:roomname])
    @booking.room_id= @room.id
    @booking.description= params[:description]
    @booking.invitees= params[:invitees]
    @startdate = Date::new(params[:startdate]["(1i)"].to_i,params[:startdate]["(2i)"].to_i,params[:startdate]["(3i)"].to_i)
    @booking.startdate= @startdate
    @booking.enddate= Date::new(params[:enddate]["(1i)"].to_i,params[:enddate]["(2i)"].to_i,params[:enddate]["(3i)"].to_i)
    @booking.starttime= Time::new(params[:starttime]["(1i)"].to_i,params[:starttime]["(2i)"].to_i,params[:starttime]["(3i)"].to_i,params[:starttime]["(4i)"].to_i,params[:starttime]["(5i)"].to_i )
    @booking.endtime= Time::new(params[:endtime]["(1i)"].to_i,params[:endtime]["(2i)"].to_i,params[:endtime]["(3i)"].to_i,params[:endtime]["(4i)"].to_i,params[:endtime]["(5i)"].to_i )
    @booking.recurring= params[:recurring]
    @booking.guid= @guid

    respond_to do |format|
      if @booking.save
        format.html { redirect_to "/rooms/",:id=> @room.id , notice: 'Booking was successfully created.' }
        format.json { render json: @booking, status: :created, location: @booking }
      else
        format.html { render action: "new" }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bookings/1
  # PUT /bookings/1.json
  def update
    @booking = Booking.find(params[:id])

    respond_to do |format|
      if @booking.update_attributes(params[:booking])
        format.html { redirect_to @booking, notice: 'Booking was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookings/1
  # DELETE /bookings/1.json
  def destroy
    @booking = Booking.find(params[:id])
    @booking.destroy

    respond_to do |format|
      format.html { redirect_to bookings_url }
      format.json { head :no_content }
    end
  end
end
