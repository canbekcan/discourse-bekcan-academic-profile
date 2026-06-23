# name: discourse-bekcan-academic-profile
# about: Bekcan platformu için gelişmiş akademik profil ve otomatik grup atama sistemi.
# version: 1.0.0
# authors: BEKCAN - Full-Stack Discourse Engineer & Architect
# url: https://github.com/canbekcan/discourse-bekcan-academic-profile
# required_version: 3.2.0

enabled_site_setting :bekcan_academic_profile_enabled

require_relative "lib/discourse_bekcan_academic_profile/engine"

add_admin_route "admin.plugins.bekcan_academic_profile.title", "academic-profile"

after_initialize do
  # Multisite ve veritabanı kontrolü sonrası güvenli başlatma
  if ActiveRecord::Base.connection.table_exists?('user_fields')
    # Veritabanı çakışmalarını ve mükerrer kayıtları önleyen servis nesnesini çağır
    ::DiscourseBekcanAcademicProfile::UserFieldBuilder.new.call
  end
  # Adım 05 & 06: Veritabanı Özel Alan (Custom Field) Kontrolü
  def setup_academic_user_fields
    # 1. academic_title (Dropdown)
    title_field = UserField.find_or_create_by!(name: "academic_title", field_type: "dropdown") do |f|
      f.description = "Akademik Ünvanınız"
      f.required = true
      f.editable = true
      f.show_on_profile = true
    end
    ["Profesör", "Doçent", "Dr. Öğr. Üyesi"].each do |opt|
      UserFieldOption.find_or_create_by!(user_field_id: title_field.id, value: opt)
    end

    # 2. academic_field (Dropdown)
    field_field = UserField.find_or_create_by!(name: "academic_field", field_type: "dropdown") do |f|
      f.description = "Akademik Alanınız"
      f.required = true
      f.editable = true
      f.show_on_profile = true
    end
    ["Temel Bilimler", "Sosyal Bilimler"].each do |opt|
      UserFieldOption.find_or_create_by!(user_field_id: field_field.id, value: opt)
    end

    # 3. scientific_disciplines (Multi-select)
    disciplines_field = UserField.find_or_create_by!(name: "scientific_disciplines", field_type: "multiselect") do |f|
      f.description = "Bilim Dalları (Alana göre filtrelenir)"
      f.required = false
      f.editable = true
      f.show_on_profile = true
    end
    ["Fizik", "Kimya", "Biyoloji", "Tarih", "Sosyoloji"].each do |opt|
      UserFieldOption.find_or_create_by!(user_field_id: disciplines_field.id, value: opt)
    end
  end

  # Sunucu başlatıldığında ve veritabanı hazır olduğunda alanları oluştur
  setup_academic_user_fields if ActiveRecord::Base.connection.table_exists?('user_fields')

  # Adım 06: Event Dinleyicileri (Kullanıcı oluşturulduğunda veya güncellendiğinde)
  DiscourseEvent.on(:user_updated) do |user|
    ::DiscourseBekcanAcademicProfile::AssignProfessorGroup.new.call(user: user)
  end

  DiscourseEvent.on(:user_created) do |user|
    ::DiscourseBekcanAcademicProfile::AssignProfessorGroup.new.call(user: user)
  end
end