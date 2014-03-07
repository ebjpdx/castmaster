require 'active_record'
require 'active_support/core_ext/date/calculations'
require 'json'
require 'logger'
require 'require_all'

require_relative 'castmaster/forecast_generator'
require_relative 'castmaster/forecast'
require_relative 'castmaster/dependency'
require_relative 'castmaster/run_shell_command'
require_relative 'castmaster/configuration'


module Castmaster

  def load_generators
    # require_rel Castmaster.generator_library
    puts Castmaster.generator_library
  end

end
# class Castmaster

#   def self.hi 
#     puts "Hello Nurse"
#   end 
# end
