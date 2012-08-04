
class BookingsController < ApplicationController

  include BookingsHelper
  include RoomsHelper
  include UsersHelper




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

    @user_id = current_user
    case params[:id]
      when "approaching"
        @bookings = Booking.paginate :conditions=>[ "user_id = #{@user_id} and enddate >= now()::date"],:page=>params[:page],:order=>'startdate desc, starttime desc', :per_page => 10
      when "history"
        @bookings = Booking.paginate :conditions=>["user_id = #{@user_id} and enddate < now()::date"],:page=>params[:page],:order=>'startdate desc, starttime desc', :per_page => 10
      when "all"
        @bookings = Booking.paginate :conditions=>["user_id = #{@user_id}"],:page=>params[:page],:order=>'startdate desc, starttime desc', :per_page => 10
      else
        @bookings = Booking.paginate :conditions=>["user_id = #{@user_id}"],:page=>params[:page],:order=>'startdate desc, starttime desc', :per_page => 10
    end

    if @bookings.nil?
      @bookings = Array.new
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bookings }
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
    _booking = Booking.find(params[:id])
    @booking = build_up_booking _booking
    access_ip = request.remote_ip
    access_user = current_user

    @room =  Room.find( @booking.room_id)

    @recurring_days = Array.new
    bits = @booking.recurringbits

    7.times do |index|
      tmp_bits = bits >> index
      if tmp_bits & 1 == 1
        @recurring_days << index
      end
    end

    @user_cookie = User.find(@booking.user_id).username

    if( cookies[:user_name] != @user_cookie)
      logger.info "#{Time.now} #{access_user} @ #{access_ip} try to edit booking #{params[:id]}"
      redirect_to("/error")
    else
      logger.info "#{Time.now} bookingid:#{params[:id]} roomid:#{params[:roomid]} edited by #{access_user} @ #{access_ip}"
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @booking }
      end
    end

  end

  # POST /bookings
  # POST /bookings.json
  def create

    # validating the input username
    tmp_user = User.find_by_username(params[:username])

    if tmp_user.nil?
      redirect_to "/validationerror"
      return
    end
    @booking_userid = tmp_user.id


    @room = Room.find_by_name(params[:roomname])
    @booking_roomid = @room.id
    #build the guid
    @guid = params[:username] +"!" +Time.now.to_i.to_s

    @booking = Booking.new(params[:booking])

    @booking.startdate = Date.strptime(params[:new_booking_start_date], "%m/%d/%Y");
    @booking.enddate = Date.strptime(params[:new_booking_end_date],"%m/%d/%Y");

    # check the invitees is good formatted
    if !check_invitees(params[:invitees])
      redirect_to :action=>"validation", :controller=>"error_handler", :id=> 1
      return
    end

    # check the start and _end in date and time
    if !check_date_and_time(@booking)
      redirect_to :action=>"validation", :controller=>"error_handler", :id=> 2
      return
    end



    @booking.user_id= @booking_userid
    @booking.room_id= @booking_roomid
    @booking.guid= @guid

    @booking.summary = params[:summary]
    @booking.description= params[:description]
    @booking.invitees= params[:invitees]

    @booking.recurring = params[:recurring]

    @recurringdays = Array.new

    if !params[:recurringday1].nil?
       @recurringdays <<  0
    end

    if !params[:recurringday2].nil?
      @recurringdays << 1
    end

    if !params[:recurringday3].nil?
      @recurringdays << 2
    end

    if !params[:recurringday4].nil?
      @recurringdays << 3
    end

    if !params[:recurringday5].nil?
      @recurringdays << 4
    end

    if !params[:recurringday6].nil?
      @recurringdays << 5
    end

    if !params[:recurringday7].nil?
      @recurringdays << 6
    end

    @booking.recurringbits = build_recurringbits @recurringdays


    if conflict_booking = check_conflicts(@booking, @recurringdays)
      redirect_to :action=>"conflict", :controller=>"error_handler", :id=> conflict_booking.id, notice: "Conflict checking."
      return
    else
      @booking.save
    end

    respond_to do |format|

      if cookies[:user_name]
          # do nothing
          cookies[:user_name] = params[:username]
          cookies[:expires] = 1.years.from_now.utc
        else
          cookies[:user_name] = params[:username]
          cookies[:expires] = 1.years.from_now.utc
        end

        access_ip = request.remote_ip
        logger.info "#{Time.now} #{params[:username]} at #{access_ip} created booking"
        Notifier.notification_mail(@booking).deliver

        format.html { redirect_to :action=>'show',:id=> @room.id ,:controller=>"rooms", notice: 'Booking was successfully created.' }
        format.json { render json: @booking, status: :created, location: @booking }

    end
  end

  # PUT /bookings/1
  # PUT /bookings/1.json
  def update

    @booking = Booking.find(params[:id])
    @booking.startdate = params[:edit_booking_start_date]
    @booking.enddate = params[:edit_booking_end_date]


    @room = Room.find_by_id(@booking.room_id)


    recurringdays = Array.new

    if !params[:recurringday1].nil?
      recurringdays <<  0
    end

    if !params[:recurringday2].nil?
      recurringdays << 1
    end

    if !params[:recurringday3].nil?
      recurringdays << 2
    end

    if !params[:recurringday4].nil?
      recurringdays << 3
    end

    if !params[:recurringday5].nil?
      recurringdays << 4
    end

    if !params[:recurringday6].nil?
      recurringdays << 5
    end

    if !params[:recurringday7].nil?
      recurringdays << 6
    end

    updated_recurringbits = build_recurringbits recurringdays

    @booking.recurringbits = updated_recurringbits

    if conflict_booking = check_conflicts(@booking, recurringdays)
      redirect_to :action=>"conflict", :controller=>"error_handler", :id=> conflict_booking.id, notice: "Conflict checking."
      return
    end

    respond_to do |format|
      if @booking.update_attributes(params[:booking].merge!({:summary=>params[:summary],:description=>params[:description],:invitees=>params[:invitees],:recurring=>params[:recurring], :recurringbits => updated_recurringbits}))
        access_ip = request.remote_ip
        logger.info "#{Time.now} booking:#{@booking} room:#{@room} updated by #{access_ip}"

        format.html { redirect_to :action=>"show", :id=>@room.id, :controller=>"rooms"}
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
    @room = Room.find_by_id(@booking.room_id)
    @user_cookie = User.find(@booking.user_id).username
    access_ip = request.remote_ip
    if cookies[:user_name] != @user_cookie
      logger.info "#{Time.now} #{access_ip} tried to delete booking#{params[:id]}"
       redirect_to("/error")
    else
      @booking.destroy
      access_ip = request.remote_ip
      logger.info "#{Time.now} booking:#{params[:id]} room:#{@room.id} deleted by #{access_ip} "
      respond_to do |format|
        #format.html { redirect_to bookings_url }
        format.html {redirect_to :action=>"show", :id=>@room.id, :controller=>"rooms"}
        format.json { head :no_content }
      end
    end


  end

  def approaching
    redirect_to  :action=>"show", :id=> 1, :controller=>"bookings"
  end

  def history
    redirect_to  :action=>"show", :id=> 2, :controller=>"bookings"
  end

  def all
    redirect_to  :action=>"show", :id=> 3, :controller=>"bookings"
  end

end
