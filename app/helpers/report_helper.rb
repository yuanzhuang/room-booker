module ReportHelper

  # statistic trigger type : AUTO, WEB, MANUALLY
  #
  def generate_statistic(source)
    start_time = Time.now
    clear_old_statistic
    room_usage_statistic
    other_statistic
    end_time = Time.now
    duration = end_time - start_time
    statistic_logging(duration, source)
  end

  def clear_old_statistic
    StatisticLog.delete_all
  end

  def need_new_statistic(last_statistic_time)
    duration = Time.now - last_statistic_time
    duration > half_day
  end

  def half_day
    60 * 60 * 12
  end

  def room_usage_statistic
    # metric : room - usage ratio in past days
    stat_room_booking_ratio
    # metric : room - booking ratio in coming days
    stat_room_booking_ratio
    # metric : room - times
    stat_room_usage_times
    # metric : room - by whom
    stat_room_booking_by
  end

  def other_statistic
    # TODO other necessary statistic
  end

  def statistic_logging(duration, type)
    log = StatisticLog.new
    log.trigger_source = type
    log.cost_time = duration
    log.save!
  end

  def stat_room_usage_ration
    # TODO stat the room usage ratio
  end

  def stat_room_booking_ratio
    # TODO
  end

  def stat_room_usage_times
    rooms = Room.all
    rooms.each do |room|
      count = Booking.where(:room_id => room.id).count
      ustat = UsageStatistic.new
      ustat.statistic_type = 1
      ustat.room_id = room.id
      ustat.metric = "usage_count"
      ustat.metric_value = "#{count}"
      ustat.save!
    end
  end

  def stat_room_booking_by
    # TODO
  end

end
