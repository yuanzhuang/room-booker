module BookingsHelper

  # this method aims at spliting one complex booking into array of date, the element of this array is the start fo each
  # single day
  def split_booking (date, days)

    logger.info '============ in split booking ==============='
    logger.info days.inspect


    return_dates = Array.new


    if days.size == 0
      return_dates << date
    end

    date_week_day = date.days_to_week_start    # 0-6

    days.each do |day|

      logger.info "date_week_day is #{day}"

      if day < date_week_day

        temp = Date.new
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


    logger.info return_dates.inspect


    logger.info "============== exit ===================="
    return return_dates

  end

  #
  # method to check the conflicts, all external requests invoke this methods
  #
  def check_conflicts (booking)
    risk_bookings_1 = select_risk_bookings_pre booking
    risk_bookings_2 = select_risk_bookings booking,risk_bookings_1
    conflict_booking = select_risk_times booking,risk_bookings_2
    return conflict_booking

  end

  def select_risk_bookings_pre(candidate_booking)
    logger.info "============== in select risk bookign pre =============="
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

    logger.info risk_bookings.inspect

    logger.info " ============== exit ================"
    return risk_bookings

  end

  def select_risk_bookings(candidate_booking, bookings)

    logger.info "================== enter select_risk_bookings ====================="

    risk_bookings = Array.new

    candidate_bits = build_day_bits2(candidate_booking)

    bookings.each do |booking|
      bits = build_day_bits(candidate_booking, booking)
      #candidate_bits = build_day_bits(candidate_booking,booking)

      if bits & candidate_bits != 0
        logger.info "============ #{bits & candidate_bits}"
        risk_bookings <<  booking
      end

    end

    logger.info "The risk bookings is "+risk_bookings.inspect

    logger.info " ============================ exit ================================="

    return risk_bookings

  end

  def build_day_bits2(booking)
    logger.info " ========================enter build_day_bits2 ==========================="
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

    logger.info "=================================exit======================================"

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

    logger.info "====================== enter select risk times ======================="

    candidate_bits = build_hour_bits( candidate_booking)



    bookings.each do |booking|
      bits = build_hour_bits booking
      if bits & candidate_bits != 0

        logger.info " ===> #{bits}"
        logger.info " ===> #{candidate_bits}"
        logger.info " ===> #{bits & candidate_bits}"
        logger.info " ================================ exit1 ====================================="
        return booking
      end
    end

    logger.info "======================exit2 ============================================"

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
    #invitees = booking.invitees
    email_pattern = /\w+((_|\.)\w+)*@\w+((_|\.)\w+)*\.\w+/

    #emails = /\w+([-_\.]\w+])*@\w+([-\.]\w+)*\.\w+(\.\w+([-_\.]\w+])*@\w+([-\.]\w+)*\.\w+)*/
    #emails =  /\w+((_|\.)\w+])*@\w+((_|\.)\w+)*\.\w+(\,\w+((_|\.)\w+])*@\w+((_|\.)\w+)*\.\w+)*/

    invitee_mails = invitees.split ','
    invitee_mails.each do |mail|

      logger.info "checking mail address "+mail

      extracted_mail = email_pattern.match mail
      if extracted_mail.nil?
        logger.info "No match for "+mail.inspect
        return false
      else
        if extracted_mail.to_s != mail
          logger.info "Can match for "+mail.inspect
          return false
        end
      end


    end

    return true

  end

end
