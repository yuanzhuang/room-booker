module BookingsHelper

  # this method aims at spliting one complex booking into array of date, the element of this array is the start fo each
  # single day
  def split_booking (date, days)
    return_dates = Array.new

    if days.size == 0
      return_dates << date
    end

    date_week_day = date.days_to_week_start    # 0-6

    days.each do |day|

      if day < date_week_day

        interval = day - date_week_day + 7
        tempdate = date
        interval.times do
          tempdate = tempdate.tomorrow
        end

        return_dates << tempdate

      elsif day == date_week_day

        return_dates << date

      elsif day > date_week_day

        interval = day - date_week_day
        tempdate = date
        interval.times do
          tempdate = tempdate.tomorrow
        end
        return_dates << tempdate
      end

    end

    return return_dates

  end

  #
  # method to check the conflicts, all external requests invoke this methods
  #
  def check_conflicts (candidate_booking, recurringdays)

    bookings = pre_process candidate_booking,recurringdays

    bookings.each do |booking|
      maybe_return = check_conflicts_for_splited booking
      if !maybe_return.nil?
        return maybe_return
      end
    end
    return nil
  end

  def pre_process booking,recurringdays

    bookings = Array.new

    dates = split_booking booking.startdate,recurringdays
    dates.each do |date|
      newbooking = Booking.new
      newbooking.user_id = booking.user_id
      newbooking.room_id = booking.room_id
      newbooking.recurring = booking.recurring
      newbooking.startdate = date
      newbooking.enddate = booking.enddate
      newbooking.starttime = booking.starttime
      newbooking.endtime = booking.endtime

      bookings << newbooking
    end

    return bookings

  end

  def check_conflicts_for_splited(booking)
    risk_bookings_1 = select_risk_bookings_pre booking
    risk_bookings_2 = select_risk_bookings booking,risk_bookings_1
    conflict_booking = select_risk_times booking,risk_bookings_2
    return conflict_booking
  end

  def check_conflicts_with_specific(booking, other_booking)
    bits = build_day_bits2 booking

    _days = Array.new
    _bits = other_booking.recurringbits
    7.times do |index|
      _tmpbits = _bits >> index
      if _tmpbits & 1 == 1
        _days << index
      end
    end
    _dates = split_booking other_booking.startdate,_days

    _bookings = Array.new
    _dates.each do |_date|
      _booking = Booking.new
      _booking.id = other_booking.id
      _booking.user_id = other_booking.user_id
      _booking.room_id = other_booking.room_id
      _booking.recurring = other_booking.recurring
      _booking.startdate = _date
      _booking.enddate = other_booking.enddate
      _booking.starttime = other_booking.starttime
      _booking.endtime = other_booking.endtime
      _bookings << _booking
    end

    _bookings.each do |_tmpbooking|
      bits2 = build_day_bits booking,_tmpbooking
      if (bits & bits2)!=0
        return true
      end
    end

    return false

  end


  def select_risk_bookings_pre(candidate_booking)
     bookings = Booking.find_all_by_room_id(candidate_booking.room_id)

     if bookings.nil?
       bookings = []
     end

    logger.info bookings.inspect

     risk_bookings = Array.new

     bookings.each do |booking|

       if booking.guid != candidate_booking.guid
         if (compare_date(booking.startdate, candidate_booking.startdate) <= 0) and (compare_date(booking.enddate,candidate_booking.enddate)>=0)
           logger.info 1
           risk_bookings <<  booking
         elsif (compare_date(booking.startdate,candidate_booking.startdate) <=0) and (compare_date(booking.enddate,candidate_booking.startdate)>=0) and (compare_date(booking.enddate,candidate_booking.enddate)<=0)
           logger.info 2
           risk_bookings <<  booking
         elsif (compare_date(booking.startdate,candidate_booking.startdate) >=0 )and (compare_date(booking.startdate, candidate_booking.enddate)<=0) and (compare_date(booking.enddate, candidate_booking.enddate)>=0)
           logger.info 3
           risk_bookings <<  booking
         elsif (compare_date(booking.startdate,candidate_booking.startdate) >=0) and (compare_date(booking.enddate, candidate_booking.enddate)<=0)
           logger.info 4
           risk_bookings <<  booking
         end
       end
     end

    return risk_bookings

  end

  def select_risk_bookings(candidate_booking, bookings)

    risk_bookings = Array.new

    candidate_bits = build_day_bits2(candidate_booking)


    bookings.each do |booking|

      _days = Array.new
      _bits = booking.recurringbits
      7.times do |index|
        _tmpbits = _bits >> index
        if _tmpbits & 1 == 1
          _days << index
        end
      end

      _dates = split_booking booking.startdate,_days

      _bookings = Array.new
      _dates.each do |_date|
        _booking = Booking.new
        _booking.id = booking.id
        _booking.user_id = booking.user_id
        _booking.room_id = booking.room_id
        _booking.recurring = booking.recurring
        _booking.startdate = _date
        _booking.enddate = booking.enddate
        _booking.starttime = booking.starttime
        _booking.endtime = booking.endtime
        _bookings << _booking
      end

      _bookings.each do |_tmpbooking|
        bits = build_day_bits(candidate_booking, _tmpbooking)

        if bits & candidate_bits != 0
          risk_bookings <<  _tmpbooking
        end
      end




    end

    return risk_bookings

  end

  def build_day_bits2(booking)
    duration_days = booking.enddate - booking.startdate + 1
    duration_times = 1
    duration_intervals = 1
    if booking.recurring == Booking::RECURRING_TYPE[0] # no recurring
      duration_times = 0
      duration_intervals = 0
    elsif booking.recurring == Booking::RECURRING_TYPE[1]            # daily
      duration_times = duration_days
      duration_intervals = 1
    elsif booking.recurring == Booking::RECURRING_TYPE[2]            # weekly
      duration_times = duration_days / 7
      duration_intervals = 7
    elsif booking.recurring == Booking::RECURRING_TYPE[3]            # bi-weekly
      duration_times = duration_days / 14
      duration_intervals = 14
    end

    day_bits = 1
    mirror_bits = day_bits

    duration_times = duration_times.round 0

    duration_times.times do
      mirror_bits = mirror_bits << duration_intervals
      day_bits = day_bits | mirror_bits
    end

    return day_bits

  end

  def build_day_bits(candidate_booking, booking)

    day_bits = build_day_bits2(booking)


    offside = booking.startdate - candidate_booking.startdate
    if offside > 0
      day_bits = day_bits << offside
    elsif offside < 0
      offside = -offside
      day_bits = day_bits >> offside
    end

    return day_bits


  end

  def build_hour_bits(booking)
    hours = 1

    starthour = booking.starttime.hour
    endhour = booking.endtime.hour
    startmin = booking.starttime.min
    endmin = booking.endtime.min

    hours = hours << ( (24-starthour)*2 -1 )

    if startmin >= 30
      hours = hours >> 1
    end

    duration = 0


    if endmin > startmin
      duration = 1
    elsif endmin == startmin
      duration = 0
    elsif endmin < startmin
      duration = -1
    end

    if endhour == starthour
      return hours
    end

    duration = duration + 2*(endhour - starthour) -1

    if duration < 0
      return hours
    end


    mirror_bits = hours
    duration.times do
      mirror_bits = mirror_bits >> 1
      hours = hours | mirror_bits
    end

    return hours

  end

  def select_risk_times(candidate_booking, bookings)

    candidate_bits = build_hour_bits( candidate_booking)

    bookings.each do |booking|
      bits = build_hour_bits booking
      if bits & candidate_bits != 0
        return booking
      end
    end

    return nil

  end

  # if date1 early than date2 return -1
  # if date1 equals date2 return 0
  # if date1 later than date2 return 1
  def compare_date(date1, date2)


    if date1.year < date2.year
      return -1
    end

    if date1.year > date2.year
      return 1
    end

    if date1.month < date2.month
      return -1
    end

    if date1.month > date2.month
      return 1
    end

    if date1.day < date2.day
      return -1
    end

    if date1.day > date2.day
      return 1
    end

    return 0

  end

  # enddate >= startdate
  # endtime > starttime
  def check_date_and_time(booking)
    if !check_start_and_end_date(booking)
      return false
    end

    if !check_start_and_end_time(booking)
      return false
    end

    return true

  end

  def check_start_and_end_date(booking)

    if booking.enddate < Date.current
      return false
    end

    if compare_date(booking.startdate,booking.enddate) <= 0
      return true
    end

    return false
  end

  def check_start_and_end_time(booking)
    if booking.starttime < booking.endtime
      return true
    end
    return false
  end

  # invitees should be in good formated. like mail,mail,mail
  def check_invitees(invitees)
    email_pattern = /\w+((_|\.)\w+)*@\w+((_|\.)\w+)*\.\w+/

    invitee_mails = split_invitees invitees
    invitee_mails.each do |mail|

      extracted_mail = email_pattern.match mail
      if extracted_mail.nil?
        return false
      else
        if extracted_mail.to_s != mail
          return false
        end
      end


    end

    return true

  end

  def split_invitees(invitees)
    _invitees = invitees.gsub " ",""
    invitee_mails = _invitees.split ','
    invitee_mails
  end

  def build_recurringbits days
    bits = 0
    days.each do |day|
      bits = bits | (1<<day)
    end
    return bits
  end

end
