class AddDevicesToRoom < ActiveRecord::Migration
  def change
    add_column :rooms, :devices, :integer
  end
end
