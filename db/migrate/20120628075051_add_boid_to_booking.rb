class AddBoidToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :boid, :string
  end
end
