# Castmaster

Castmaster is a tool to manage forecast runs (i.e. a taskmaster for forecasts).  It provides a framework for defining a forecast procedure (`Forecast Generator`) and tracking specific runs of those procedures (`Forecast Run`). 

`Forecast Generators` have four components:
- Parameters: Inputs that the forecast can accept at runtime
- Dependencies: Other Forecast Generators, whose output is neeby the current Generator, including data/measurem
- Procedure: The code that will modify input data to producforecast
- Metadata: Information that will be stored about the forecast, such as the forecast start and end dates

Whenever a `Forecast Generator` is called, Castmaster will check to see if its dependencies have a matching `Forecast Run`, and call any that don't. Then it will look to see if a valid run of the `Forecast Generator` already exists with the same parameters and dependency runs. If no existing forecast run is found, the procedure is run and a new `Forecast Run` is created, which stores input parameters used for that run and the identity of the dependency runs it used. 

Castmaster was created primarily to handle cases where there is an "ecosystem" of forecasts---forecasts are built on top of multiple other forecasts or data sources, each of which may have different procedures, dependencies, or input parameters. For example, a forecast of return volume might depend how many orders are forecast, which in turn depends upon a set of historical data. 

## Installation

Add this line to your application's Gemfile:

    gem 'castmaster'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install castmaster

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
