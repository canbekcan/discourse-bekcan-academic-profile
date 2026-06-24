# name: discourse-bekcan-academic-profile
# about: Gelişmiş akademik profil yönetimi ve otomatik grup atama sistemi.
# version: 1.4.0
# authors: BEKCAN - Full-Stack Discourse Engineer
# url: https://github.com/canbekcan/discourse-bekcan-academic-profile
# required_version: 3.2.0

enabled_site_setting :bekcan_academic_profile_enabled
add_admin_route "admin.plugins.academic_profile.title", "academic-profile"

after_initialize do
  # Eklenti yüklendiğinde alanları oluştur
  if ActiveRecord::Base.connection.table_exists?('user_fields')
    ::DiscourseBekcanAcademicProfile::UserFieldBuilder.new.call
  end

  # Kullanıcı güncellendiğinde veya oluştuğunda grupları kontrol et
  DiscourseEvent.on(:user_updated) { |user| ::DiscourseBekcanAcademicProfile::AssignAcademicGroups.new.call(user: user) }
  DiscourseEvent.on(:user_created) { |user| ::DiscourseBekcanAcademicProfile::AssignAcademicGroups.new.call(user: user) }
end