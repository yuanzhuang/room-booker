
class BookingsController < ApplicationController

  include BookingsHelper
  include RoomsHelper

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

    #@bookings = Booking.find_all_by_user_id(params[:id])
    @bookings = Booking.paginate :conditions=>["user_id = #{params[:id]}"],:page=>params[:page],:order=>'startdate desc, starttime desc', :per_page => 10

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
    logger.info "#{Time.now} #{params[:roomid]} create"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @booking }
    end
  end

  # GET /bookings/1/edit
  def edit
    _booking = Booking.find(params[:id])

    @booking = build_up_booking _booking

    @room =  Room.find( @booking.room_id)
    logger.info "#{Time.now} bookingid:#{params[:id]} roomid:#{params[:roomid]} edit"

    @recurring_days = Array.new
    bits = @booking.recurringbits

    7.times do |index|
      tmp_bits = bits >> index
      if tmp_bits & 1 == 1
        @recurring_days << index
      end
    end


    @year = 2012
    @month =   7

    @user_cookie = User.find(@booking.user_id).username
    #puts cookies[:user_name]
    #puts @user_cookie
    if( cookies[:user_name] != @user_cookie)
      redirect_to("/error")
    else
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
    logger.info "#{Time.now} #{params[:username]} create"

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

    # check the invitees is good formatted
    if !check_invitees(params[:invitees])
      redirect_to :action=>"validation", :controller=>"error_handler", :id=> 1
      return
    end

    # check the start and _end in date and time
    if !check_date_and_time(@booking)
      #redirect_to "/validationerror"
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

    logger.info '============================'
    logger.info @booking.recurringbits
    logger.info params[:recurringday1]
    logger.info params[:recurringday2]
    logger.info params[:recurringday3]
    logger.info params[:recurringday4]
    logger.info params[:recurringday5]
    logger.info params[:recurringday6]
    logger.info params[:recurringday7]

    logger.info @recurringdays.inspect
    logger.info '============================'



    respond_to do |format|

        if cookies[:user_name]
          # do nothing
          cookies[:user_name] = params[:username]
          cookies[:expires] = 1.years.from_now.utc
        else
          cookies[:user_name] = params[:username]
          cookies[:expires] = 1.years.from_now.utc
        end

        Notifier.notification_mail(@booking).deliver

        format.html { redirect_to :action=>'show',:id=> @room.id ,:controller=>"rooms", notice: 'Booking was successfully created.' }
        format.json { render json: @booking, status: :created, location: @booking }

    end
  end

  # PUT /bookings/1
  # PUT /bookings/1.json
  def update

    @booking = Booking.find(params[:id])

    @room = Room.find_by_id(@booking.room_id)
    logger.info "#{Time.now} booking:#{@booking} room:#{@room} update"

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

    respond_to do |format|
      if @booking.update_attributes(params[:booking].merge!({:summary=>params[:summary],:description=>params[:description],:invitees=>params[:invitees],:recurring=>params[:recurring], :recurringbits => updated_recurringbits}))

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
    logger.info "#{Time.now} booking:#{@booking} room:#{@room} delete"

    if cookies[:user_name] != @user_cookie
       redirect_to("/error")
    else
      @booking.destroy

      respond_to do |format|
        #format.html { redirect_to bookings_url }
        format.html {redirect_to :action=>"show", :id=>@room.id, :controller=>"rooms"}
        format.json { head :no_content }
      end
    end


  end
end
