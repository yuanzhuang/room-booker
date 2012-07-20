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


    devices_requirement = 0

    if !params[:projector].nil?
      devices_requirement |= 1
    end

    if !params[:telephone].nil?
      devices_requirement |= 2
    end

    # recurring requirements
    @required_booking.recurring = params[:recurring]

    # capacity requirement
    capacity_requirement = params[:capacity]


    @rooms = get_available_rooms @required_booking, devices_requirement, capacity_requirement

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

    respond_to do |format|
      format.html
      format.json {render :xml => @booking }
    end

  end

end
