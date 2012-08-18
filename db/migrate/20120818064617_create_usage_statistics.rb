class CreateUsageStatistics < ActiveRecord::Migration

  # statistic type :
  # 1 - room
  # 2 - other


  def change
    create_table :usage_statistics do |t|
      t.references :room
      t.references :user

      t.integer :statistic_type
      t.string :metric
      t.string :metric_value

      t.timestamps
    end
  end
end
