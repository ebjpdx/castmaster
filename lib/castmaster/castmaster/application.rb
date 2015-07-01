module Castmaster

  class Application

    def initialize(configuration_file = nil)
      Castmaster.load_configuration(configuration_file) if configuration_file       
      initialize_application_database_connection
      load_generators
    end


    def load_generators
      require_all Castmaster.generator_library
    end

    def initialize_application_database_connection
        ActiveRecord::Base.establish_connection(Castmaster.database_configurations[Castmaster.environment])
    end


  end


end
