task :cast, [:file_name] => [:environment] do |task, args|
  require 'yaml'
  require 'erb'

  RUN_DATE = (ENV["RUN_DATE"] || Date.yesterday).to_date

  jobs_file = args.file_name || ENV["JOBS_FILE"]
  raise ArgumentError, "The jobs file isn't specified." unless jobs_file
  raise ArgumentError, "Jobs files should be in the yaml format" unless /yml$/ =~ jobs_file

  JOBS = YAML.load(ERB.new(IO.read(jobs_file)).result)


  Rails.logger.info "Starting Forecast Jobs from #{jobs_file} \n"
  JOBS.each do |nm,job|
    Rails.logger.info "Running #{job[:generator]}"
    begin
      fcst = job[:generator].to_s.constantize.build(job[:parameters])
      fcst.run(ENV["FORCE_REFRESH"])
    rescue Exception => e
      Rails.logger.error "#{job[:generator]} stopped with error:\n #{e}"
      raise e unless Rails.env == "production"
    end
  end

  Rails.logger.info "Forecast Jobs Complete"
end


