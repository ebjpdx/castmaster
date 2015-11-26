class ForecastGenerator

  attr_accessor  :forecast_id, :dependencies, :parameters

  REQUIRED_FIELDS = {
      name: [String],
      grain: [Symbol],
      target_table: [Symbol,String],
      partitioned_table: [TrueClass,FalseClass],
      type: [Symbol],
      training_start: [Date],
      training_end: [Date],
      forecast_start: [Date],
      forecast_end: [Date]}
  attr_accessor *REQUIRED_FIELDS.keys 
 
  FORECAST_IDENTIFIERS = [:name,:target_table,:grain, :parameters] 


  def self.default_parameters
    @default_parameters ||= {}    
  end


  def self.default_parameters=(param_hash)
    raise TypeError, "Default parameters must be specified as a hash." unless param_hash.is_a?(Hash)
    @default_parameters = param_hash 
  end
  

  def self.build(param = {})
    merged_param = merge_default_parameters(param.except(:dependencies))
    forecast_generator = self.new(merged_param)
    # merged_param = merge_default_parameters(param)
    # forecast_generator = self.new(merged_param.except(:dependencies))
    # merged_param[:dependencies] = param[:dependencies] unless param[:dependencies].nil? 
    forecast_generator.parameters = merged_param
    forecast_generator.name = self.name
    forecast_generator.merge_dependencies!(param[:dependencies] || {} )
    forecast_generator.validate!
    forecast_generator
  end  

  def self.reload!  #Reloads class to help development in an interactive session
    load_all Castmaster::Configuration.generator_library { |lib| File.join(lib, '**', self.name.underscore || '.rb')}
  end



  def validate!
    REQUIRED_FIELDS.each do |field,type| 
      raise ArgumentError, "The field '#{field.to_s}' was not initialized" if self.send(field).nil? 
      raise TypeError, "The field '#{field.to_s}' should be #{type} not #{self.send(field).class}" unless  type.include?(self.send(field).class)
    end
    raise RangeError, "The training period start date is after its end date" unless training_start <= training_end
    raise RangeError, "The forecast period start date is after its end date" unless forecast_start <= forecast_end

    self.dependencies.each {|n,d| d.validate!}
    true
  end


  def self.merge_default_parameters(param)
    param.each do |field,v|
      warn "'#{field.to_s}' is not a default parameter of #{self.name}. Are you passing this through to a dependency?" unless self.default_parameters.keys.include?(field)
      raise TypeError, "The field '#{field.to_s}' should be #{self.default_parameters[field].class} not #{v.class}" unless !self.default_parameters.keys.include?(field) || v.is_a?(self.default_parameters[field].class)  
    end
    self.default_parameters.merge(param) 
  end
 

  def merge_dependencies!(dep = {})
    dep.each do |field,v|
      raise ArgumentError, "#{self.name} does not include '#{field}' as one of its dependencies: #{self.dependencies.keys}."  unless self.dependencies.keys.include?(field)
      # The TypeError below was failing in one case -- ConversionPredictionData and ConversionPredictionDataNextSeason.  These tables have the same structure, but need to be recreated each time, which is not currently guaranteed.
      # raise TypeError, "The #{field} dependency needs to have a target table of #{self.dependencies[field].target_table}, not #{v.target_table}." unless v.target_table == self.dependencies[field].target_table
    end
    self.dependencies.merge!(dep) 
  end


  def get_next_forecast_id
    ActiveRecord::Base.connection.execute("select nextval('forecasting.forecast_id_seq') ").first['nextval'].to_i
  end

  def identification_conditions
    ic = self.instance_values.symbolize_keys.slice(*FORECAST_IDENTIFIERS)
    ic[:parameters] = ic[:parameters].to_json
    ic 
  end

  def forecasts_field_values
    iv = instance_values.symbolize_keys
    iv.merge!(
              #id: get_next_forecast_id,
              parameters: (parameters.nil?)? '' :  parameters.to_json
              )
    iv.slice(*Forecast.column_names.map {|c| c.to_sym} )
  end


  def find_existing_forecast_run
    # conn.verify!
    forecasts = Forecast.where(identification_conditions.merge({date_reaped: nil, status: 'completed'})).order('id desc')
    current_dependencies = {}
    self.dependencies.each { |n,d|  current_dependencies[n] = d.forecast_id unless d.parameters[:ephemeral] }


    if forecasts.empty? or current_dependencies.any? {|id|  id.nil?}  
      return nil
    else 
      if self.parameters[:ephemeral]
        #Ephemeral forecasts always run unless the latest forecast_run for the table is a match
        latest_forecast_id_in_table = Forecast.where({target_table: self.target_table}).order('id desc').first.id
        forecasts.select! {|f| f.id == latest_forecast_id_in_table} #Only check the lastest forecast run for ephemeral tables 
      end

      forecasts.select! do |f|
          old_dependencies = Hash[f.dependencies.map do |fd|
            #Manual backfill dependency name as needed. 
            raise "forecast_dependencies.dependency_name needs to be manually backfilled for #{fd.forecast_id}, #{fd.name}, #{fd.dependency_id}"  if fd.dependency_name.nil? 
            [fd.dependency_name.to_sym,fd.dependency_id]
           end
          ]
         (current_dependencies.to_a - old_dependencies.to_a).empty?
      end
      if forecasts.length > 1 then 
        Castmaster.log.warn {"The forecast_identifiers for #{name} do not specify a unique forecast id. Unless you have specified the force_refresh option, this is an error.
           Forecast ID's returned: #{forecasts.map {|f| f.id}}
           Criteria: #{identification_conditions}
           Dependencies: #{current_dependencies}"}
      end
      return forecasts.first
    end
  end


  def forecast_run
    @forecast_run ||= find_existing_forecast_run
  end

  def forecast_run=(forecast)
    @forecast_run = forecast
  end

  def forecast_id 
    if forecast_run then forecast_run.id end
  end

  def dependencies 
    @dependencies ||= {}
  end

  def add_partitions
    self.target_table.to_s.split(/ *, */).each do |target|
      sql = "alter table forecasting_pdata.#{target}
             add partition  id#{self.forecast_id} values (#{self.forecast_id}) 
             WITH (APPENDONLY=true, COMPRESSLEVEL=6, COMPRESSTYPE=zlib, OIDS=FALSE )"
      Castmaster.query(sql)
    end
  end

  def partitioned_table? 
    @partitioned_table
  end

  def run(force_refresh=false, debug=false, log_indent='')
    if debug 
      puts sql
      return "Finished Debugging"
    end

    ActiveRecord::Base.connection.verify!
    force_refresh = force_refresh.to_sym if force_refresh.is_a? String

    Castmaster.log.info {"#{log_indent}#{name}--Checking Dependencies:"} unless @dependencies.length == 0 
    @dependencies.each do |n,d| 

      if d.forecast_run.nil? || force_refresh == :all
        Castmaster.log.info {"#{log_indent + '  '}#{n}--No matching forecast; force_refresh = #{force_refresh.to_s}"}
        d.run((if force_refresh == :all then force_refresh end), debug, (log_indent ||'') + '    ')
      else 
        Castmaster.log.info {"#{log_indent + '  '}#{n}--Using existing forecast: #{d.forecast_id}"}
      end
    end

    if self.forecast_run.nil? || force_refresh
      Castmaster.log.info {"#{log_indent}#{name}--Generating new forecast: force_refresh = '#{force_refresh.to_s}', parameters = #{self.parameters.except(:dependencies)} "}
        self.forecast_run = Forecast.new(forecasts_field_values)
        self.forecast_run.id = get_next_forecast_id
        self.forecast_run.status = "started"
        self.forecast_run.dependencies.new @dependencies.map { |n,d| {dependency_id: d.forecast_id, name: d.name, target_table: d.target_table, dependency_name: n.to_s} } unless @dependencies.nil? || @dependencies.empty?
        self.forecast_run.save
      begin
        add_partitions if self.partitioned_table?
        if self.type == :sql and self.sql
            Castmaster.execute(self.sql)
        end
        forecast_procedure   #Always run forecast procedure -- to allow post-hoc processing
        ActiveRecord::Base.connection.verify!
        self.forecast_run.update_attributes(status:  "completed")
        # self.forecast_run.save
        Castmaster.log.info {"#{log_indent}#{name}--Finished forecast run: forecast_id = #{self.forecast_run.id}."}    
      rescue StandardError => e
        self.forecast_run.update_attributes(status: "error", error_message: e) 
        Castmaster.log.error e
        raise e       
      end
    else
      Castmaster.log.info {"#{log_indent}#{name}--Using existing forecast: forecast_id = #{self.forecast_id}, force_refresh = '#{force_refresh.to_s}', parameters = #{self.parameters}"} 
    end
    forecast_run
  end

  def forecast_procedure
  end

  def sql
  end


  def map_dependencies
    mp = {}
    mp[:forecast_id] = self.forecast_id    
    unless self.dependencies.empty?
      dep_map = {}
      self.dependencies.each do |n,f|
        dep_map[n] = f.map_dependencies
      end
      mp[:dependencies] = dep_map
    end
    mp 
  end

  def summarize
    puts self.map_dependencies.to_yaml
  end



end
