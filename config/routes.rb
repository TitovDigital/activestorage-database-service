Rails.application.routes.draw do

  get  "/rails/active_storage/database/:encoded_key/*filename" => "active_storage/database#show", as: :rails_database_service
  put  "/rails/active_storage/database/:encoded_token" => "active_storage/database#update", as: :update_rails_database_service

end
