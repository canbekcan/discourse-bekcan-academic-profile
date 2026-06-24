# name: discourse-bekcan-academic-profile
# about: Gelişmiş akademik profil yönetimi ve otomatik grup atama sistemi.
# version: 1.4.0
# authors: BEKCAN - Full-Stack Discourse Engineer
# url: https://github.com/canbekcan/discourse-bekcan-academic-profile
# required_version: 3.2.0

enabled_site_setting :bekcan_academic_profile_enabled

require_relative "lib/discourse_bekcan_academic_profile/engine"

# Admin panelinde sol menü bağlantısı (Kendi namespace'i ile)
add_admin_route "bekcan_academic_profile.title", "academic-profile"

# Backend Engine Rotalarını uygulamaya ekliyoruz
Discourse::Application.routes.append do
  mount ::DiscourseBekcanAcademicProfile::Engine, at: "/admin/plugins/academic-profile", constraints: AdminConstraint.new
end

after_initialize do
  # Engine içindeki rotaların tanımlanması
  DiscourseBekcanAcademicProfile::Engine.routes.draw do
    get "/" => "academic_profile#index"
    post "/sync" => "academic_profile#sync"
  end

  # Veritabanı tabloları hazır olduğunda alanları senkronize et
  if ActiveRecord::Base.connection.table_exists?('user_fields')
    ::DiscourseBekcanAcademicProfile::UserFieldBuilder.new.call
  end
  
  # Event işleyicileri (Modern ve güvenli)
  DiscourseEvent.on(:user_updated) do |user|
    ::DiscourseBekcanAcademicProfile::AssignAcademicGroups.new.call(user: user)
  end

  DiscourseEvent.on(:user_created) do |user|
    ::DiscourseBekcanAcademicProfile::AssignAcademicGroups.new.call(user: user)
  end
end