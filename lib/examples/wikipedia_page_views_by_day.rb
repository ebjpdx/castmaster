 class WikipediaPageViewsByDay < Measurement

  self.default_parameters= {:run_date => Date.yesterday}


  def initialize(param={})
    self.target_table   = "data/examples/wikipedia_pageviews_by_day.csv"
    self.type           = :ruby
    self.grain          = :day
    self.training_start = '2016-01-01'.to_date
    self.training_end   = param[:run_date]
    self.forecast_start = self.training_start
    self.forecast_end   = self.training_end

    self.dependencies= {}

  end


  def forecast_procedure
    require 'net/http'
    require 'csv'


    begin
      current_file = CSV.read(target_table)
      max_date = current_file.map {|r| r[0]}.max
    rescue
      puts "File doesn't exist yet, it will be created"
    end


    start_date = (max_date || '2016-01-01').to_date
    end_date = Date.yesterday

    if start_date < end_date
      url = "https://wikimedia.org/api/rest_v1/metrics/pageviews/aggregate/en.wikipedia/all-access/user/daily/" +
           "#{start_date.strftime('%Y%m%d00')}/#{end_date.strftime('%Y%m%d00')}"
      resp = Net::HTTP.get_response(URI.parse(url))
      items = JSON.parse(resp.body)['items']
      CSV.open(target_table,'a') do |csv|
        items.each {|r| csv << [r['timestamp'].to_date.to_s,r['views']]}
      end
    else
      puts "The latest date has already been recorded"
    end


  end

end

