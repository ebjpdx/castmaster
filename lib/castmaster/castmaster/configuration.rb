module Castmaster

  module Configuration
    extend self

    require 'erb'
    require 'yaml'
    require 'json'


    attr_accessor :generator_library, :config_dir, :log_dir, :initializer_dir,
                  :database_config_file, :log_file, :environment

    @environment          = ENV["DB_ENV"] || ENV["RAILS_ENV"] || "development"
    @config_dir           = 'config'
    @generator_library    = 'lib'
    @log_dir              = 'logs'
    @initializer_dir      = 'initializers' 

    @config_file          = File.join(@config_dir,'config.yml')
    @database_config_file = File.join(@config_dir,'database.yml')
    @log_file             = File.join(@log_dir,'castmaster.log')
    

    def configure
      yield self
    end


    def load_configuration(config)
      params = config.is_a?(Hash) ? config : load_config_file(config)
      params.each  do |param, value| 
        self.instance_variable_set("@#{param}",value)
      end
    end


    def load_config_file(config_file)
        if config_file =~ /\.yml$/  
            YAML.load(ERB.new(IO.read(config_file)).result)
        elsif config_file =~ /\.json$/
            JSON.parse(ERB.new(IO.read(config_file)).result)
        else 
            raise ArgumentError, "The configuration file, '#{config_file}', is not of a supported type (JSON, YAML)."
        end
    end


    def database_configurations
        load_config_file(self.database_config_file)
    end



### THIS IS RAFTER SPECIFIC AND SHOULD GO IN TEST APP
    # def notifierConfig
    #   load_config_fileYAML("notifier")[configEnv]
    # end

  
  end

end



