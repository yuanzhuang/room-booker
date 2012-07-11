module BookingsHelper

  # this method aims at spliting one complex booking into array of date, the element of this array is the start fo each
  # single day
  def split_booking (date, days)

    return_dates = Array.new

    if days.size = 0
      return_dates.append date
    end

    date_week_day = date.days_to_week_start

    days.each do |day|

      if day < date_week_day

        temp = Date.new
        interval = day - date_week_day + 7
        tempdate = date
        interval.times do
          tempdate = tempdate.tomorrow
        end

      elsif day == date_week_day

        return_dates.append date

      elsif day > date_week_day

        interval = day - date_week_day
        tempdate = date
        interval.times do
          tempdate = tempdate.tomorrow
        end
        return_dates.append tempdate
      end

    end

    return return_dates

  end

  #
  # method to check the conflicts, all external requests invoke this methods
  #
  def check_conflicts (booking)
    risk_bookings_1 = select_risk_bookings_pre booking
    risk_bookings_2 = select_risk_bookings booking,risk_bookings_1
    flag = select_risk_times booking,risk_bookings_2
    return flag

  end

  def select_risk_bookings_pre(candidate_booking)
     bookings = Booking.all

     risk_bookings = Array.new

     bookings.each do |booking|

       if booking.guid != candidate_booking.guid
         if (compare_date(booking.startdate, candidate_booking.startdate) <= 0) and (compare_date(booking.enddate,candidate_booking.enddate)>=0)
           risk_bookings.append booking
         elsif (compare_date(booking.startdate,candidate_booking.startdate) <=0) and (compare_date(booking.enddate,candidate_booking.startdate)>=0) and (compare_date(booking.enddate,candidate_booking.enddate)<=0)
           risk_bookings.append booking
         elsif (compare_date(booking.startdate,candidate_booking.startdate) >=0 )and (compare_date(booking.startdate, candidate_booking.enddate)>=0) and (compare_date(booking.enddate, candidate_booking.enddate)>=0)
           risk_bookings.append booking
         elsif (compare_date(booking.startdate,candidate_booking.startdate) >=0) and (compare_date(booking.enddate, candidate_booking.enddate)<=0)
           risk_bookings.append booking
         end
       end
     end
    return risk_bookings

  end

  def select_risk_bookings(candidate_booking, bookings)

    risk_bookings = Array.new

    candidate_bits = build_day_bits2(candidate_booking)

    bookings.each do |booking|
      bits = build_day_bits(candidate_booking, booking)
      #candidate_bits = build_day_bits(candidate_booking,booking)

      if bits & candidate_bits
        risk_bookings.append booking
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

    if startmin < 30
      hours = hours >> 1
    end

    duration = 0
    if endmin > startmin
      duration = 1
    elsif endmin = startmin
      duration = 0
    elsif endmin < startmin
      duration = -1
    end

    duration = duration + 2*(endhour - starthour)

    if duration < 0
      return 0
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
      if bits & candidate_bits
        return true
      end
    end


    return false

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

end
