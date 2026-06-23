# name: discourse-bekcan-academic-profile
# about: Gelişmiş akademik profil ve otomatik grup atama sistemi. Yönetici paneli senkronizasyonlu.
# version: 1.2.0
# authors: BEKCAN - Full-Stack Discourse Engineer & Architect
# url: https://github.com/canbekcan/discourse-bekcan-academic-profile
# required_version: 3.2.0

enabled_site_setting :bekcan_academic_profile_enabled

require_relative "lib/discourse_bekcan_academic_profile/engine"

# Admin panel sol menü bağlantısı
add_admin_route "bekcan_academic_profile.title", "academic-profile"

Discourse::Application.routes.append do
  mount ::DiscourseBekcanAcademicProfile::Engine, at: "/admin/plugins/academic-profile", constraints: AdminConstraint.new
end

after_initialize do
  # Arka uç API rotalarının çizilmesi
  DiscourseBekcanAcademicProfile::Engine.routes.draw do
    get "/" => "academic_profile#index"
    post "/sync" => "academic_profile#sync"
  end

  # Veritabanı çakışmalarını önleyen güvenli başlatma
  if ActiveRecord::Base.connection.table_exists?('user_fields')
    ::DiscourseBekcanAcademicProfile::UserFieldBuilder.new.call
  end
  
  # Otomatik grup atama event'leri
  DiscourseEvent.on(:user_updated) do |user|
    ::DiscourseBekcanAcademicProfile::AssignProfessorGroup.new.call(user: user)
  end

  DiscourseEvent.on(:user_created) do |user|
    ::DiscourseBekcanAcademicProfile::AssignProfessorGroup.new.call(user: user)
  end
end