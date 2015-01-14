
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require "grape"
require 'grape/tokeeo'
require 'active_record'
require 'database_cleaner'
require 'factory_girl'
require "rack/test"
require "dm-core"
require "dm-migrations"
require "mongo_mapper"
require "orm_adapter"

ENV["RAILS_ENV"] = "test"

RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  I18n.enforce_available_locales = false
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => ':memory:'
  )

  load File.dirname(__FILE__) + '/support/schema.rb'

  # Initialize MongoMapper access.
  MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
  MongoMapper.database = "test"

  # Initialize Mongoid configuration.

  # Initialize support with DataMapper
  DataMapper.setup(:default, 'sqlite::memory:')


  Dir["#{File.dirname(__FILE__)}/support/models/*.rb"].each {|f| require f}
  Dir["#{File.dirname(__FILE__)}/factories/*.rb"].each {|f| require f }
  Dir["#{File.dirname(__FILE__)}/support/*.rb"].each{ |f| require f }

  # Finalize models declaration for DataMapper
  DataMapper.finalize
  DataMapper.auto_migrate!

  # methods or matchers
  require 'rspec/expectations'
  config.include RSpec::Matchers
  config.include Rack::Test::Methods

  # == Mock Framework
  config.mock_with :rspec

  include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end

  RSpec.configure do |config|
    config.include Rack::Test::Methods
  end

end
