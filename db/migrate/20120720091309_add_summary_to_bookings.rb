class AddSummaryToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :summary, :string
  end
end
