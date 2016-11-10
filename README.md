# Castmaster

Castmaster is a tool to manage forecast runs (i.e. a taskmaster for forecasts).  It provides a framework for defining a forecast procedure (`Forecast Generator`) and tracking specific runs of those procedures (`Forecast Run`). 

`Forecast Generators` have four components:
- Parameters: Inputs that the forecast can accept at runtime
- Dependencies: Other Forecast Generators, whose output is needed by the current Generator, including data/measurements
- Procedure: The code that will modify input data to producforecast
- Metadata: Information that will be stored about the forecast, such as the forecast start and end dates

Whenever a `Forecast Generator` is called, Castmaster will check to see if its dependencies have a matching `Forecast Run`, and call any that don't. Then it will look to see if a valid run of the `Forecast Generator` already exists with the same parameters and dependent runs. If no existing forecast run is found, the procedure is run and a new `Forecast Run` is created. 

Castmaster was created primarily to handle cases where there is an "ecosystem" of forecasts: forecasts are built on top of multiple other forecasts or data sources, each of which may have different procedures, dependencies, or input parameters. For example, a forecast of return volume might depend how many orders are forecast, which in turn depends upon a set of historical data. 

## Installation
Castmaster has no front-end, but it is currently deployed as a Rails app in order to simplify installation, take advantage of Rails migration tasks, and utilize the console. 

After cloning the repo, execute:

    $ bundle install

Change the `config/database.yml` file to point to a live database (otherwise it will default to a local SQLite database), and run the  rails database creation/migration tasks:

    $ rails db:migrate


##Usage

####Interactive
The rails console can be used to run forecasts interactively. To run a forecast, first, create a new Forecast Generator object using the `build` method, and then run that object.

    rails console
    wp = Examples::WikipediaPageViewsByDay.build
    wp.run

The `build` method will accept parameter values for the forecast as arguments. If no parameter hash is given, default parameters, defined in the Forecast Generator will be used.

    wp = Examples::WikipediaPageViewsByDay.build(run_date: Date.today)

If there is already a matching `ForecastRun`, calling the `run` method will not execute the forecast, but will simply return the matching run. If a forecast does need to be executed again (say during development), it can be run with the `force_refresh` option.

    wp.run(force_refresh: true)
    wp.run(force_refresh: :all)

If `force_refresh` is set to `:all`, the dependecies of the forecast  (and their dependencies) will be refreshed, otherwise just the parent forecast will be refreshed.

####Non-Interactive
The `cast` rake task can be used to run one or more forecasts in a non-interactive manner. This task expects to receive a filename that references a YAML configuration file giving the forecast generators to run, and any parameters for them. 

    rails "cast[/Users/eric.johnson/Downloads/wiki_job.yml]"

## Authoring Forecast Generators

Forecast Generators are created by writing Ruby classes that inherit from `ForecastGenerator`.  Castmaster expects that the `initialize` method for the class will set some required meta-data values about the forecast, and that the class will have a body to be executed. 

This body will either be a `forecast_procedure` method that will be executed in Ruby, or if `type = 'sql'`, it can be a `sql` method containing a query string.  

The example file shows basic syntax:

    ./forecast_generators/examples/wikipedia_page_views_by_day.rb

####Dependencies
  Dependencies are added in the `self.dependencies` hash. The hash key should be a descriptive name for the dependency, and the value should be a built `ForecastGenerator` object.

####File Locations

Forecast Generators will be autoloaded if they are placed in the `forecast_generators` folder. However, they need to follow Rails naming conventions. The filename should be the class name in underscore, and generators located in a subfolder need to either be namespaced or placed in a module with the subfolder name. 

The example file above should have the class name:

    class Examples::WikipediaPageViewsByDay < Measurement
      ...
    end


