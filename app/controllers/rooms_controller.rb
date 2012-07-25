class RoomsController < ApplicationController

  include RoomsHelper

  # To change this template use File | Settings | File Templates.
  def index
    @rooms = Room.all.sort { |a,b| a.capacity <=> b.capacity }

    respond_to do |format|
      format.html
      format.js
      format.xml  { render :xml => @rooms}
    end

  end

  def show
    @room = Room.find(params[:id])

    all_bookings = Booking.find_all_by_room_id(@room.id).sort{|a,b| a.created_at <=> b.created_at}
    @bookings = Array.new
    guid_array = Array.new

    all_bookings.each do | single_basic_booking|
      bookings_with_same_guid = Booking.find_all_by_guid(single_basic_booking.guid)
      booking = build_up_booking_group guid_array,bookings_with_same_guid
      if !booking.nil?
        @bookings << booking
        guid_array << single_basic_booking.guid
      end
    end

    respond_to do |format|
      format.html
      format.xml { render :xml => @room}
    end

  end

  def create
    @room = Room.new(params[:room])
    logger.info "#{Time.now} #{params[:room]} create"


    respond_to do |format|
      if @room.save
        format.html {redirect_to(@room,:notice=> 'Room was successfully created.')}
        format.xml {render :xml => @room, :status => :created, :location => @room}
      else
        format.html {render :action => "new"}
        format.xml {render :xml => @room.errors, :status => :unprocessable_entity}
      end
    end

  end

  def new
    @room = Room.new
    logger.info "#{Time.now} room:#{@room} create"

    respond_to do |format|
      format.html
      format.xml {render :xml => @room}
    end
  end

  def edit
    @room = Room.find(params[:id])
    logger.info "#{Time.now} room:#{@room} edit"

  end

  def update
    @room = Room.find(params[:id])
    logger.info "#{Time.now} #{params[:id]} update"
    respond_to do |format|
      if @room.update_attributes(params[:room])
        format.html {redirect_to(@room,:notice => 'Room was successfully updated.')}
        format.xml {head :ok}
      else
        format.html {render :action => "edit"}
        format.xml  {render :xml => @room.errors, :status => :unprocessable_entity}
      end
    end
  end

  def destroy
    @room = Room.find(params[:id])
    logger.info "#{Time.now} #{params[:id]} delete"
    @room.destroy

    respond_to do |format|
      format.html  {redirect_to(rooms_url)}
      format.xml {head :ok}
    end

  end

end
