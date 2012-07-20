module SearchHelper

  include BookingsHelper

  def get_available_rooms(booking, devices, capacity)

    available_room = Array.new
    rooms = get_all_rooms

    rooms.each do |room|
      if !check_conflicts_with_room booking,room.id
          available_room << room
      end
    end

    return available_room

  end

  # return true => conflict, false => no conflict
  def check_conflicts_with_room(booking, roomid)

    bookings = Booking.find_all_by_room_id( roomid )

    bookings.each do |booking_at_room|
      if check_conflicts_with_specific booking,booking_at_room
        return true
      end
    end

    return false

  end

  def get_all_rooms
    rooms = Room.all
    return rooms
  end

  def build_room_details room
    room_desc = room.roomnum.to_s + ' '+ room.name + ' '+room.cname+ ' F' + room.location.to_s
    return room_desc
  end

end
