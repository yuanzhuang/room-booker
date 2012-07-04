class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.integer :roomnum
      t.string :name
      t.string :cname
      t.integer :capacity
      t.string :location

      t.timestamps
    end
  end
end
