# frozen_string_literal: true
# name: discourse-bekcan-academic-profile
# about: Gelişmiş akademik profil yönetimi ve otomatik grup atama sistemi.
# version: 1.4.0
# authors: BEKCAN - Full-Stack Discourse Engineer
# url: https://github.com/canbekcan/discourse-bekcan-academic-profile
# minimum_discourse_version: 3.2.0.beta1

require_relative "lib/discourse_bekcan_academic_profile/engine"
enabled_site_setting :bekcan_academic_profile_enabled

# 1. Engine tanımlaması (Namespace çakışmalarını önler)
# app/controllers/discourse_bekcan_academic_profile/academic_profile_controller.rb
# frozen_string_literal: true

module ::DiscourseBekcanAcademicProfile
  class AcademicProfileController < ::Admin::AdminController
    requires_plugin "discourse-bekcan-academic-profile"

    def index
      render json: {
        titles: SiteSetting.bekcan_academic_titles.split("|").map(&:strip).reject(&:blank?),
        mappings: PluginStore.get("bekcan_academic_profile", "group_mappings") || {},
        groups: Group.select(:id, :name).map { |g| { id: g.id, name: g.name } }
      }
    end

    def sync
      # Using Service Object pattern for clean business logic execution
      # Pre-condition: Mappings must be present and valid
      result = ::DiscourseBekcanAcademicProfile::AssignAcademicGroups.call(
        mappings: params.require(:mappings)
      )

      if result.success?
        render json: success_json
      else
        render json: { errors: result.errors }, status: :unprocessable_entity
      end
    end
  end
end

# 2. Rota Mount İşlemi (AdminConstraint ile GÜVENLİ)
Discourse::Application.routes.append do
  mount ::DiscourseBekcanAcademicProfile::Engine, at: "/admin/plugins/academic-profile", constraints: AdminConstraint.new
end

# 3. Admin Paneli Linki (I18n anahtarı ile eşleşmeli)
add_admin_route "admin.plugins.academic_profile.title", "academic-profile"

# Register the admin stylesheet
register_asset "stylesheets/admin/academic-profile.scss", :admin

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