class RoomsController < ApplicationController
  # To change this template use File | Settings | File Templates.
  def index
    @rooms = Room.all.sort { |a,b| a.capacity <=> b.capacity }

    respond_to do |format|
      format.html
      format.xml  { render :xml => @rooms}
    end

  end

  def show
    @room = Room.find(params[:id])
    @bookings = Booking.find_all_by_room_id(@room.id)

    respond_to do |format|
      format.html
      format.xml { render :xml => @room}
    end

  end

  def create
    @room = Room.new(params[:room])

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

    respond_to do |format|
      format.html
      format.xml {render :xml => @room}
    end
  end

  def edit
    @room = Room.find(params[:id])
  end

  def update
    @room = Room.find(params[:id])

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
    @room.destroy

    respond_to do |format|
      format.html  {redirect_to(rooms_url)}
      format.xml {head :ok}
    end

  end

end
