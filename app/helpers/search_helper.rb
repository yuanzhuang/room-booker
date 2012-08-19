module SearchHelper

  include BookingsHelper

  def get_available_rooms(booking, devices, capacity, recurring_days)

    available_room = Array.new
    rooms = get_all_rooms

    rooms.each do |room|
      if !check_conflicts_with_room booking,room,devices,capacity,recurring_days
          available_room << room
      end
    end

    return available_room

  end

  # return true => conflict, false => no conflict
  def check_conflicts_with_room(booking, room, devices, capacity, recurring_days)

    if devices != room.devices
      if devices != 0
        return true
      end
    end

    logger.info "capacity is #{capacity.to_i} and rooms capacity is #{room.capacity}"
    if !capacity.nil?

      if capacity.to_i > room.capacity
        return true
      end
    end

    dates = split_booking booking.startdate,recurring_days

    splited_bookings = Array.new
    dates.each do |date|
      tmp_booking = Booking.new
      tmp_booking.enddate = booking.enddate
      tmp_booking.starttime = booking.starttime
      tmp_booking.endtime = booking.endtime
      tmp_booking.recurring = booking.recurring
      tmp_booking.startdate = date
      splited_bookings << tmp_booking
    end

    bookings = Booking.find_all_by_room_id room.id



    bookings.each do |booking_at_room|

      splited_bookings.each do |splited_booking|
        if check_conflicts_with_specific splited_booking,booking_at_room
          hour_bits_1 = build_hour_bits splited_booking
          hour_bits_2 = build_hour_bits booking_at_room
          if hour_bits_1 & hour_bits_2 != 0
            return true
          end
        end
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

  def build_params(booking,devices,capacity, recurring_days, n)
    today = DateTime.now.strftime("%m/%d/%Y")
    {
      :starttime => booking.starttime,
      :endtime => n.to_s,
      :devices => devices,
      :capacity => capacity,
      :startdate => today,
      :enddate => today
    }

  end

end
