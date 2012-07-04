class User < ActiveRecord::Base
  attr_accessible :admin, :passwd, :username
end
