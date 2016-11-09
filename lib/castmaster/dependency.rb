class Dependency < ActiveRecord::Base
    self.table_name='dependencies'
    self.primary_key = 'id'
    belongs_to :forecast, primary_key: 'id', foreign_key: 'forecast_id'
    has_one :dependent_forecast, class_name: 'Forecast', primary_key: 'dependency_id', foreign_key: 'id'


end


