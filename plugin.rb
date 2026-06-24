# frozen_string_literal: true
# name: discourse-bekcan-academic-profile
# about: Gelişmiş akademik profil yönetimi ve otomatik grup atama sistemi.
# version: 1.4.0
# authors: BEKCAN - Full-Stack Discourse Engineer
# url: https://github.com/canbekcan/discourse-bekcan-academic-profile
# required_version: 3.2.0

require_relative "lib/discourse_bekcan_academic_profile/engine"
enabled_site_setting :bekcan_academic_profile_enabled

# 1. Engine tanımlaması (Namespace çakışmalarını önler)
module ::DiscourseBekcanAcademicProfile
  class Engine < ::Rails::Engine
    engine_name "discourse_bekcan_academic_profile"
    isolate_namespace DiscourseBekcanAcademicProfile
  end
end

# 2. Rota Mount İşlemi (AdminConstraint ile GÜVENLİ)
Discourse::Application.routes.append do
  mount ::DiscourseBekcanAcademicProfile::Engine, at: "/admin/plugins/academic-profile", constraints: AdminConstraint.new
end

# 3. Admin Paneli Linki (I18n anahtarı ile eşleşmeli)
add_admin_route "admin.plugins.academic_profile.title", "academic-profile"

after_initialize do
  # 4. Engine rotalarının tanımı (Sadece engine içi özel rotalar)
  DiscourseBekcanAcademicProfile::Engine.routes.draw do
    get "/" => "academic_profile#index"
    post "/sync" => "academic_profile#sync"
  end

  # 5. Başlatma Mantığı
  # table_exists? kontrolü, veritabanı migrate edilmemişken (ilk kurulumda) eklentinin çökmesini engeller.
  if ActiveRecord::Base.connection.table_exists?('user_fields')
    ::DiscourseBekcanAcademicProfile::UserFieldBuilder.new.call
  end

  # Olay dinleyicileri (Thread-safe servis çağrıları)
  DiscourseEvent.on(:user_updated) do |user|
    ::DiscourseBekcanAcademicProfile::AssignAcademicGroups.new.call(user: user)
  end

  DiscourseEvent.on(:user_created) do |user|
    ::DiscourseBekcanAcademicProfile::AssignAcademicGroups.new.call(user: user)
  end
end