class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.references :room
      t.references :user
      t.string :description
      t.string :invitees
      t.date :startdate
      t.date :enddate
      t.time :starttime
      t.time :endtime
      t.string :recurring

      t.timestamps
    end
    add_index :bookings, :room_id
    add_index :bookings, :user_id
  end
end
