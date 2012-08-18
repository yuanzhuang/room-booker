class CreateStatisticLogs < ActiveRecord::Migration
  def change
    create_table :statistic_logs do |t|
      t.string :trigger_source
      t.string :cost_time

      t.timestamps
    end
  end
end
