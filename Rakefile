task :environment do
  load './environment.rb'
end

namespace :db do
  desc "Migrate the database"
  task(:migrate => :environment) do
    require 'logger'
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::MigrationContext.new("db/migrate", ActiveRecord::SchemaMigration).migrate
  end
end
