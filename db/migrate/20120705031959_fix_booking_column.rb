class FixBookingColumn < ActiveRecord::Migration
  def change
    rename_column :bookings, :boid, :guid
  end
end
