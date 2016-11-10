class CreateDependencyRuns < ActiveRecord::Migration[5.0]
  def change
    create_table :dependency_runs do |t|
      t.integer :forecast_run_id            , :null => false
      t.integer :dependent_forecast_run_id  , :null => false
      t.text :name                          , :null => false
      t.text :target_table                  , :null => false
      t.text :dependency_name               , :null => false
      t.timestamps
    end
  end
end
