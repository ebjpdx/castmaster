class Forecast < ActiveRecord::Base
  self.table_name='forecasting.forecasts'
  self.primary_key = 'id'
  has_many :dependencies, :primary_key => 'id', :foreign_key => 'forecast_id'

  def reap!(log_indent='')
    
    LOG.info "#{log_indent}Forecast #{id} was already reaped on #{date_reaped}. Reaping again." unless date_reaped.nil?
    if !living_parents.empty?
      LOG.info "#{log_indent}Cannot reap forecast #{id}, #{name}! It is a dependency of forecasts #{self.living_parents.map {|p| p.id}}"  
      return false 
    else
      begin 
        delete_target_table_values!
        update_attributes(date_reaped: Time.now) if date_reaped.nil?
        LOG.info "#{log_indent}Reaped forecast #{id}, #{name}"
        LOG.info "#{log_indent}Checking if #{dependencies.length} dependencies can be reaped:" if dependencies.length > 0
        dependencies.each { |d| d.dependent_forecast.reap!(log_indent + '  ') }
      rescue Exception => e 
        update_attributes(date_reaped: nil)
        raise "Reap failed. Some dependencies may not have been deleted. \n #{e}"
      end
      return true
    end
  end

  def living_parents
    Dependency.where(dependency_id: self.id).map { |p| p.forecast if p.forecast.date_reaped.nil?}.compact
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
              LOG.info "Not deleting values from table: #{target}. It doesn't have a forecast_id field."
            else
              raise e2
            end
          end
        elsif e.to_s =~ /ERROR:  partition .+ does not exist/  #Don't raise an error if the partition has already been deleted
          LOG.info "This partition for #{target}, #{self.id} has already been deleted."
        else
          raise e
        end
      end
    end
    true
  end


end
