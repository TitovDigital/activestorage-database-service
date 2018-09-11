# Activestorage::Database::Service
ActiveStorage database service to store binary files in a database.

Tested with PostgreSQL.

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

