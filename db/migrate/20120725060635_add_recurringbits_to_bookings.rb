class AddRecurringbitsToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :recurringbits, :integer
  end
end
