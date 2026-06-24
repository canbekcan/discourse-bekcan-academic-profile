# config/routes.rb
DiscourseBekcanAcademicProfile::Engine.routes.draw do
  get "/data" => "academic_profile#index"
  post "/sync" => "academic_profile#sync"
end