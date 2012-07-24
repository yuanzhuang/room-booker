class SearchController < ApplicationController

  include SearchHelper

  def search
    @booking = Booking.new

    respond_to do |format|
      format.html
      format.json {render :xml=>@booking}
    end

  end

  def result

    @required_booking = Booking.new params[:booking]

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



    respond_to do |format|
      format.html
      format.json {render :xml => @booking }
    end

  end

end
