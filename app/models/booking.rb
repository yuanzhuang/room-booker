class Booking < ActiveRecord::Base

  RECURRING_TYPE = ["NO_RECURRING","DAILY","WEEKLY","BI_MONTHLY"]

  belongs_to :room
  belongs_to :user
  attr_accessible :description, :enddate, :endtime, :invitees, :recurring, :startdate, :starttime
end
