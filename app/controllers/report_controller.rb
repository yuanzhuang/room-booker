class ReportController < ApplicationController

  include ReportHelper

  # show report result
  def report
    last_log = StatisticLog.order(:created_at).last
    unless last_log.nil?
      last_statistic_time = last_log.created_at
      generate_statistic("auto") if need_new_statistic(last_statistic_time)
    else
      generate_statistic("auto")
    end

    @usage_statistics = UsageStatistic.all
    respond_to do |format|
      format.html
    end
  end

  # invoke statistic func
  def statistic
    generate_statistic("web")
  end

end
