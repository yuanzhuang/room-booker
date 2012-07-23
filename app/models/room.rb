class Room < ActiveRecord::Base
  attr_accessible :capacity, :cname, :location, :name, :roomnum, :devices
end
