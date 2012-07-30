module IcsHelper

  def build_ics_location(room)
    location = room.roomnum.to_s+":"+room.name+":"+room.cname+" at Floor : "+room.location
    return location
  end

  # return time hash
  # key = [:dtstart, :dtend, :dtstamp, :last_modified]
  def build_ics_time(booking)
    times = Hash.new
    start_date = booking.startdate
    end_date = booking.enddate
    start_time = booking.starttime
    end_time = booking.endtime

    dtstart = Time.new start_date.year,start_date.month,start_date.day,start_time.hour,start_time.min,start_time.sec
    dtend = Time.new start_date.year,start_date.month,start_date.day,end_time.hour,end_time.min,end_time.sec
    dtstamp = Time.now
    last_modified = Time.now

    times.store :dtstart,dtstart.getutc
    times.store :dtend,dtend.getutc
    times.store :dtstamp, dtstamp.getutc
    times.store :last_modified, last_modified.getutc

    return times

  end


  def generate_ics(booking)

    user = User.find booking.user_id
    room = Room.find booking.room_id
    generated_location = build_ics_location room
    time_hash = build_ics_time booking
    invitees = split_invitees booking.invitees

    cal = RiCal.Calendar do |cal|
      cal.event do |event|
        event.summary = booking.description
        event.description = booking.description
        event.dtstart = time_hash[:dtstart]
        event.dtend = time_hash[:dtend]
        event.dtstamp = time_hash[:dtstamp]
        event.last_modified = time_hash[:last_modified]
        event.organizer = user.username
        event.location = generated_location

        invitees.each do |invitee|
          event.add_attendee invitee
        end
      end
    end
  end

  def split_invitees(invitees)
    _invitees = invitees.gsub " ",""
    invitee_a = _invitees.split(",")
    return invitee_a
  end

end
