class AddBoidToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :boid, :string # boid = Booking Operation ID
  end
end
