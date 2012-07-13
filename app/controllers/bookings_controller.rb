
class BookingsController < ApplicationController

  include BookingsHelper

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
    @room =  Room.find(params[:roomid])

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
    @booking_userid = User.find_by_username(params[:username]).id
    @room = Room.find_by_name(params[:roomname])
    @booking_roomid = @room.id
    @guid = params[:username] +"!" +Time.now.to_i.to_s

    @booking = Booking.new(params[:booking])


    @booking.user_id= @booking_userid
    @booking.room_id= @booking_roomid
    @booking.guid= @guid

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

    logger.info '============================'
    logger.info params[:recurringday1]
    logger.info params[:recurringday2]
    logger.info params[:recurringday3]
    logger.info params[:recurringday4]
    logger.info params[:recurringday5]
    logger.info params[:recurringday6]
    logger.info params[:recurringday7]

    logger.info @recurringdays.inspect
    logger.info '============================'

    dates = split_booking( @booking.startdate ,@recurringdays)

    flag = 0

    # save all splited booking
    dates.each do |date|

      newbooking = Booking.new(params[:booking])
      newbooking.user_id = @booking_userid
      newbooking.room_id = @booking_roomid
      newbooking.guid = @guid
      newbooking.description= params[:description]
      newbooking.invitees= params[:invitees]
      newbooking.recurring =  params[:recurring]

      newbooking.startdate = date

      logger.info newbooking.inspect

      if check_conflicts newbooking
        redirect_to "/conflicterror"
        return
      end

      if newbooking.save
        flag = flag + 1
      else
        # need error handler
        logger.info "Error"
      end
    end





    respond_to do |format|
      if flag == dates.size
        if cookies[:user_name]
          # do nothing
          cookies[:user_name] = params[:username]
          cookies[:expires] = 1.years.from_now.utc
        else
          cookies[:user_name] = params[:username]
          cookies[:expires] = 1.years.from_now.utc
        end
        format.html { redirect_to :action=>'show',:id=> @room.id ,:controller=>"rooms", notice: 'Booking was successfully created.' }
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

    @room = Room.find_by_id(@booking.room_id)

    respond_to do |format|
      if @booking.update_attributes(params[:booking].merge!({:description=>params[:description],:invitees=>params[:invitees],:recurring=>params[:recurring]}))

        format.html { redirect_to :action=>"show", :id=>@room.id, :controller=>"rooms", notice: "Booking was successfully updated."}
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
