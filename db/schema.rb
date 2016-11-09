ActiveRecord::Schema.define do
  create_table("forecast_runs", :force => false)  do |t|
      t.text :name          , :null => false
      t.text :target_table  , :null => false
      t.text :grain         , :null => false
      t.date :training_start, :null => false
      t.date :training_end  , :null => false
      t.date :forecast_start, :null => false
      t.date :forecast_end  , :null => false
      t.text :parameters
      # t.datetime :created_at, :null => false
      t.date :date_reaped
      t.text :status
      t.text :error_message
  end

  create_table("dependent_runs", :force => false) do |t|
    t.integer  :forecast_id          , :null => false
    t.integer  :dependency_id        , :null => false
    t.text :name                     , :null => false
    t.text :target_table             , :null => false
    t.text :dependency_name          , :null => false
    # t.datetime :created_at           , :null => false
  end
end