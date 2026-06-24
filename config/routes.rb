# frozen_string_literal: true

DiscourseBekcanAcademicProfile::Engine.routes.draw do
  # Retrieve plugin configuration and data
  get "/data" => "academic_profile#index"
  
  # Sync academic group configurations
  post "/sync" => "academic_profile#sync"
end