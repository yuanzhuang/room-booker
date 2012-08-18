module CommonHelper

  def one_min
    60
  end

  def n_min(mins)
    mins.is_a?(String) ? mins.to_i * one_min : mins * one_min
  end

  def one_hour
    60 * 60
  end

  def one_day
    one_hour * 24
  end

  def n_hour(hours)
    hours.is_a?(String) ? hours.to_i * one_hour : hours * one_hour
  end

  def duration_options
    options = []
    options << ['30 mins', 30]
    options << ['1 hour', 60]
    options << ['1 hour 30 mins', 90]
    options << ['2 hours', 120]
    options << ['2 hours 30 mins', 150]
    options << ['3 hours', 180]
    options << ['Maybe Longer', 240]
  end

  # to get the next hour or hour-30mins
  def format_time(time)
    hour = time.hour
    min = time.min
    if min >= 30
      hour += 1
      min = 0
    else
      min = 30
    end

    d = Time.now
    Time.new(d.year,d.month,d.day,hour,min,0)

  end

end