module RoomsHelper

  def build_up_booking single_booking
    bookings = Booking.find_all_by_guid single_booking.guid
    booking = build_up_booking_group nil,bookings
    return booking
  end

  def build_up_booking_group  guids, candidate_bookings
    if candidate_bookings.size == 0
      return nil
    end

    if candidate_bookings.size == 1
      return candidate_bookings[0]
    end

    guid = candidate_bookings[0].guid

    if !guids.nil?
      guids.each do |g|
        if g == guid
          return nil
        end
      end
    end


    booking = candidate_bookings[0]
    dates = get_all_dates candidate_bookings
    earliest_date = get_earliest_start_date dates

    logger.info "earliest date is #{earliest_date}"

    bits = build_up_bits candidate_bookings

    booking.startdate = earliest_date
    booking.recurringbits = bits

    return booking

  end

  def build_up_bits bookings
    bits = 0
    bookings.each do |booking|
      logger.info booking.startdate.to_s
      logger.info booking.startdate.wday.to_s
      offset = (booking.startdate.wday + 6) % 7
      bits = bits | (1 << offset)
      logger.info bits
    end
    return bits
  end

  def get_all_dates bookings
    dates = Array.new
    bookings.each do |booking|
      dates << booking.startdate
    end
    return dates
  end

  def get_earliest_start_date dates

    earliest_date = dates[0]

    dates.each do |date|
      if date < earliest_date
        earliest_date = date
      end
    end

    return earliest_date

  end

end
