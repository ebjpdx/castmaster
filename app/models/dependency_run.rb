class DependencyRun < ApplicationRecord
    belongs_to :forecast_run, primary_key: 'id', foreign_key: 'forecast_run_id'
    has_one :dependency_forecast_run, class_name: 'ForecastRun', primary_key: 'dependent_forecast_run_id', foreign_key: 'id'

end
