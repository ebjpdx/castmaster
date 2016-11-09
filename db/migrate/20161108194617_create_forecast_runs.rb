class CreateForecastRuns < ActiveRecord::Migration[5.0]
  def change
    create_table :forecast_runs do |t|
      t.text :name          , :null => false
      t.text :target_table  , :null => false
      t.text :grain         , :null => false
      t.date :training_start
      t.date :training_end
      t.date :forecast_start
      t.date :forecast_end
      t.text :parameters
      t.date :date_reaped
      t.text :status
      t.text :error_message
      t.timestamps
    end
  end
end
