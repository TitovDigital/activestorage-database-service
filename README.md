# Activestorage::Database::Service
ActiveStorage database service to store binary files in a database.

The implementation is based on a standard Rails Active Storage service:
https://guides.rubyonrails.org/active_storage_overview.html
The gem adds a migration with a new model: an extra table that stores blob contents in a binary field.
The service creates and destroys records in this table as requested by Active Storage.

Therefore, this service, once installed, can be consumed via a standard Rails Active Storage API.

Please be aware of all pros and cons of using a database for storing files before using it in production.
With the right database it will provide full ACID support and can wrap file storage and deletion into transactions. It is also much easier in DevOps as there is one less service to configure.
Large files or large traffic are the risky cases. Either will put an unnecessary strain on the app and database servers.

This gem has been tested with PostgreSQL.

TODO: Implement download controller with secure tokens similar to
https://github.com/rails/rails/blob/master/activestorage/app/controllers/active_storage/disk_controller.rb

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'activestorage-database-service', github: 'TitovDigital/activestorage-database-service'
```

And then execute:
```bash
$ bundle
```

Add following lines to the `config/storage.yml`:
```
db:
  service: Database
```

Enable new storage service in `development.rb` and `production.rb` environments:
```ruby
config.active_storage.service = :db
```

Copy and run database migration:
```bash
$ rake activestorage_database_service_engine:install:migrations
$ rails db:migrate
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

