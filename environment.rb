require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => File.join(ENV['DATADIR'] || 'db', 'lmnopuz.sqlite')
)
