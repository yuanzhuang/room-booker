class Booking < ActiveRecord::Base

  RECURRING_TYPE = ["NO_RECURRING","DAILY","WEEKLY","BI_WEEKLY"]
  RECURRING_DAY = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday']
  belongs_to :room
  belongs_to :user
  attr_accessible :description, :enddate, :endtime, :invitees, :recurring, :startdate, :starttime

  validates :room_id , :presence => true
  validates :user_id , :presence => true

end
