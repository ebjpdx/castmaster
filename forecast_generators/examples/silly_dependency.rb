# module Examples
 class Examples::SillyDependency < ForecastGenerator

  self.default_parameters= {run_date: Date.yesterday, message: "World"}


  def initialize(param={})
    self.target_table   = File.join('data','examples','hello_word_dependency')
    self.type           = :ruby
    self.grain          = :day
    self.training_start = param[:run_date]
    self.training_end   = param[:run_date]
    self.forecast_start = self.training_start
    self.forecast_end   = self.training_end

    self.dependencies= {}

  end


  def forecast_procedure
    File.open("#{target_table}_#{forecast_id}.txt",'w') do |f|
      f.puts parameters[:message]
      f.puts Time.now
    end
  end

end

