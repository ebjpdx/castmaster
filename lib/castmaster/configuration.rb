

module Castmaster

  module Configuration
    require 'erb'
    require 'yaml'
    require 'json'

    DEFAULT_GENERATOR_LIBRARY = 'lib'
    DEFAULT_CONFIG_DIR = 'config'
    DEFAULT_LOG_DIR = 'logs'
    DEFAULT_INITIALIZER_DIR = nil 

    DEFAULT_DATABASE_CONFIG_FILE = 'database.yml'
    DEFAULT_LOG_FILE = 'castmaster.log'

    attr_accessor :generator_library, :config_dir, :log_dir, :initializer_dir, :database_config_file, :log_file

    # Make sure we have the default values set when we get 'extended'
    def self.extended(base)
      base.reset
    end
 
    def reset
      self.generator_library    = DEFAULT_GENERATOR_LIBRARY
      self.config_dir           = DEFAULT_CONFIG_DIR
      self.initializer_dir      = DEFAULT_INITIALIZER_DIR

      self.database_config_file = DEFAULT_DATABASE_CONFIG_FILE
    end

    def configure
      yield self
    end


    def configEnv
        ENV["DB_ENV"] || "development"
    end


    def loadConfigFile(config_file)
        if config_file =~ /\.yml$/  
            YAML.load(ERB.new(IO.read(File.join(self.config_dir,"#{config_file}" ))).result)
        elsif config_file =~ /\.json$/
            JSON.parse(ERB.new(IO.read(File.join(self.config_dir,"#{config_file}" ))).result)
        else 
            raise ArgumentError, "The configuration file, '#{config_file}', is not of a supported type (JSON, YAML)."
        end
    end


    def dbConfig
        loadConfigFile(self.database_config_file)[configEnv]
    end

    def load_generators
      require_rel Castmaster.generator_library
    end


### THIS IS RAFTER SPECIFIC AND SHOULD GO IN TEST APP
    # def notifierConfig
    #   loadConfigFileYAML("notifier")[configEnv]
    # end

  
  end

  extend Configuration

end



