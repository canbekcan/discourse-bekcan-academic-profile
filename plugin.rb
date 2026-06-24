# name: discourse-bekcan-academic-profile
# about: Gelişmiş akademik profil ve otomatik grup atama sistemi.
# version: 1.4.0
# authors: BEKCAN - Full-Stack Discourse Engineer
# required_version: 3.2.0

enabled_site_setting :bekcan_academic_profile_enabled

require_relative "lib/discourse_bekcan_academic_profile/engine"

# Rota Tanımlaması (Birebir Discourse Standartları)
add_admin_route "bekcan_academic_profile.title", "academic-profile"

Discourse::Application.routes.append do
  mount ::DiscourseBekcanAcademicProfile::Engine, at: "/admin/plugins/academic-profile", constraints: AdminConstraint.new
end

after_initialize do
  DiscourseBekcanAcademicProfile::Engine.routes.draw do
    get "/" => "academic_profile#index"
    post "/sync" => "academic_profile#sync"
  end

  if ActiveRecord::Base.connection.table_exists?('user_fields')
    ::DiscourseBekcanAcademicProfile::UserFieldBuilder.new.call
  end
  
  DiscourseEvent.on(:user_updated) { |user| ::DiscourseBekcanAcademicProfile::AssignAcademicGroups.new.call(user: user) }
  DiscourseEvent.on(:user_created) { |user| ::DiscourseBekcanAcademicProfile::AssignAcademicGroups.new.call(user: user) }
end