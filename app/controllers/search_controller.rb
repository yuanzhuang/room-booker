class SearchController < ApplicationController

  include SearchHelper
  include CommonHelper

  def search
    @booking = Booking.new

    respond_to do |format|
      format.html
      format.json {render :xml=>@booking}
    end

  end

  def result

    @required_booking = Booking.new params[:booking]

    # start-end date range

    start_date_str = params[:startdate]
    end_date_str = params[:enddate]

    @required_booking.startdate = Date.strptime(start_date_str,"%m/%d/%Y")
    @required_booking.enddate = Date.strptime(end_date_str,"%m/%d/%Y")

    @required_booking.endtime = @required_booking.starttime + n_min(params[:endtime])

    # device requirements

    logger.info "Search available rooms with the arguments :"+@required_booking.to_s

    @devices_requirement = 0

    if !params[:projector].nil?
      @devices_requirement |= 1
    end

    if !params[:telephone].nil?
      @devices_requirement |= 2
    end

    # recurring requirements
    @required_booking.recurring = params[:recurring]


    # more recurring day information
    @recurring_days = Array.new

    if !params[:recurringday1].nil?
      @recurring_days <<  0
    end

    if !params[:recurringday2].nil?
      @recurring_days << 1
    end

    if !params[:recurringday3].nil?
      @recurring_days << 2
    end

    if !params[:recurringday4].nil?
      @recurring_days << 3
    end

    if !params[:recurringday5].nil?
      @recurring_days << 4
    end

    if !params[:recurringday6].nil?
      @recurring_days << 5
    end

    if !params[:recurringday7].nil?
      @recurring_days << 6
    end


    # capacity requirement
    @capacity_requirement = params[:capacity]


    @rooms = get_available_rooms @required_booking, @devices_requirement, @capacity_requirement , @recurring_days

    respond_to do |format|
      format.html
      format.json {render :xml=>@rooms}
    end


  end

  def confirm

    @booking = Booking.new params[:booking]
    @booking.endtime = @booking.starttime + n_min(params[:endtime])

    @room = Room.find(params[:room])
    #@room_name = build_room_details room
    @room_name = @room.name

    @recurring = params[:recurring]

    @devices_requirement = 0

    if !params[:projector].nil?
      @devices_requirement |= 1
    end

    if !params[:telephone].nil?
      @devices_requirement |= 2
    end


    # more recurring day information
    @recurring_days = Array.new

    if !params[:recurringday1].nil?
      @recurring_days <<  0
    end

    if !params[:recurringday2].nil?
      @recurring_days << 1
    end

    if !params[:recurringday3].nil?
      @recurring_days << 2
    end

    if !params[:recurringday4].nil?
      @recurring_days << 3
    end

    if !params[:recurringday5].nil?
      @recurring_days << 4
    end

    if !params[:recurringday6].nil?
      @recurring_days << 5
    end

    if !params[:recurringday7].nil?
      @recurring_days << 6
    end

    @confirm_start_date = params[:startdate]
    @confirm_end_date = params[:enddate]

    respond_to do |format|
      format.html
      format.json {render :xml => @booking }
    end

  end

  def confirmmm

    @booking = Booking.new
    @booking.starttime = params[:starttime]
    @booking.endtime = @booking.starttime + n_min(params[:endtime])

    @room = Room.find(params[:room])
    #@room_name = build_room_details room
    @room_name = @room.name

    @recurring = params[:recurring]

    @devices_requirement = 0

    if !params[:projector].nil?
      @devices_requirement |= 1
    end

    if !params[:telephone].nil?
      @devices_requirement |= 2
    end


    # more recurring day information
    @recurring_days = Array.new

    if !params[:recurringday1].nil?
      @recurring_days <<  0
    end

    if !params[:recurringday2].nil?
      @recurring_days << 1
    end

    if !params[:recurringday3].nil?
      @recurring_days << 2
    end

    if !params[:recurringday4].nil?
      @recurring_days << 3
    end

    if !params[:recurringday5].nil?
      @recurring_days << 4
    end

    if !params[:recurringday6].nil?
      @recurring_days << 5
    end

    if !params[:recurringday7].nil?
      @recurring_days << 6
    end

    @confirm_start_date = params[:startdate]
    @confirm_end_date = params[:enddate]

    respond_to do |format|
      format.html
      format.json {render :xml => @booking }
    end

  end

  # to list the free room right now
  # to list the free room in following hours
  # to list the free room today
  def goodluck

    start_date = Date.new
    end_date = Date.new

    start_time = format_time(Time.now)
    end_time_1 = start_time + one_hour
    end_time_2 = start_time + one_hour * 1.5
    end_time_3 = start_time + one_hour * 2

    devices = 0
    capacity = nil
    recurring_days = []

    booking = Booking.new
    booking.startdate = start_date
    booking.enddate = end_date
    booking.starttime = start_time
    booking.endtime = end_time_1

    rooms_1 = get_available_rooms(booking, devices, capacity, recurring_days)
    booking.endtime = end_time_2
    rooms_2 = get_available_rooms(booking, devices, capacity, recurring_days)
    booking.endtime = end_time_3
    rooms_3 = get_available_rooms(booking, devices, capacity, recurring_days)

    @g1_duration = "#{start_time} to #{end_time_1}"
    @g2_duration = "#{start_time} to #{end_time_2}"
    @g3_duration = "#{start_time} to #{end_time_3}"
    @rooms_g1 = rooms_1 - rooms_2
    @rooms_g2 = rooms_2 - rooms_3
    @rooms_g3 = rooms_3
    @params_1 = build_params(booking,devices,capacity,recurring_days, 60)
    @params_2 = build_params(booking,devices,capacity,recurring_days, 90)
    @params_3 = build_params(booking,devices,capacity,recurring_days, 120)
  end

end
