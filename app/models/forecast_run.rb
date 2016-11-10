class ForecastRun < ApplicationRecord
  has_many :dependency_runs, :primary_key => 'id', :foreign_key => 'forecast_run_id'

  def reap!(log_indent='')

    Rails.logger.info "#{log_indent}Forecast #{id} was already reaped on #{date_reaped}. Reaping again." unless date_reaped.nil?
    if !living_parents.empty?
      Rails.logger.info "#{log_indent}Cannot reap forecast #{id}, #{name}! It is a dependency of forecasts #{self.living_parents.map {|p| p.id}}"
      return false
    else
      begin
        delete_target_table_values!
        update_attributes(date_reaped: Time.now) if date_reaped.nil?
        Rails.logger.info "#{log_indent}Reaped forecast #{id}, #{name}"
        Rails.logger.info "#{log_indent}Checking if #{dependencies.length} dependencies can be reaped:" if dependencies.length > 0
        dependencies.each { |d| d.dependent_forecast.reap!(log_indent + '  ') }
      rescue Exception => e
        update_attributes(date_reaped: nil)
        raise "Reap failed. Some dependencies may not have been deleted. \n #{e}"
      end
      return true
    end
  end

  def living_parents
    DependencyRun.where(dependent_forecast_run_id: self.id).map { |p| p.forecast_run if p.forecast_run.date_reaped.nil?}.compact
  end

  def delete_target_table_values!
    self.target_table.to_s.split(/ *, */).each do |target|
      ## Note: whether a table is partitioned is currently not defined at the ForecastGenerator class level (it's an instance variable),
      ## until the ability to determine whether a table is paritioned is added, this hack is needed as a workaround
      begin
        sql = "alter table forecasting_pdata.#{target} drop partition id#{self.id}"
        Castmaster.query(sql)
      rescue Exception => e
        if e.to_s =~ /ERROR:  relation .+ does not exist/
          begin
            sql = "delete from forecasting.#{target} where forecast_id = #{self.id}"
            Castmaster.query(sql)
          rescue Exception => e2
            if e2.to_s =~ /ERROR:  column "forecast_id" does not exist/
              Rails.logger.info "Not deleting values from table: #{target}. It doesn't have a forecast_id field."
            else
              raise e2
            end
          end
        elsif e.to_s =~ /ERROR:  partition .+ does not exist/  #Don't raise an error if the partition has already been deleted
          Rails.logger.info "This partition for #{target}, #{self.id} has already been deleted."
        else
          raise e
        end
      end
    end
    true
  end

end
