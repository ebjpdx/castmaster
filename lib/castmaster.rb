require 'active_record'
require 'active_support/core_ext/date/calculations'
require 'json'
require 'logger'
require 'require_all'

require_rel 'castmaster/**/*.rb'



module Castmaster

    def self.initialize(configuration_file = nil)
      Castmaster::Configuration.load_configuration(configuration_file) if configuration_file
      @@log = Logger.new(Castmaster::Configuration.log_file)
      initialize_application_database_connection
      load_initializers
      load_generators
    end

    def self.log
       @@log
    end

    def self.load_generators
      require_all Castmaster::Configuration.generator_library
    end

    def self.initialize_application_database_connection
        ActiveRecord::Base.establish_connection(Castmaster::Configuration.database_configurations[Castmaster::Configuration.environment])
    end

    def self.load_initializers
      require_all Castmaster::Configuration.initializer_dir if Dir.exists?(Castmaster::Configuration.initializer_dir)

    end


end


