# module Examples
 class Examples::HelloWorld < ForecastGenerator

  self.default_parameters= {run_date: Date.yesterday, message: "World"}


  def initialize(param={})
    self.target_table   = File.join('data','examples','hello_world.txt')
    self.type           = :ruby
    self.grain          = :day
    self.training_start = param[:run_date]
    self.training_end   = param[:run_date]
    self.forecast_start = self.training_start
    self.forecast_end   = self.training_end

    self.dependencies= {
      example_dependency: Examples::SillyDependency.build(message: param[:message])
    }

  end


  def forecast_procedure
    lines = IO.readlines("#{dependencies[:example_dependency].target_table}_#{dependencies[:example_dependency].forecast_id}.txt")
    File.open(self.target_table,'w') do |f|
      f.puts "Hello #{lines[0].strip}"
      f.puts "Dependency Run = #{dependencies[:example_dependency].forecast_id}"
    end
  end

end

