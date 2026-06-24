# frozen_string_literal: true

module ::DiscourseBekcanAcademicProfile
  class UserFieldBuilder
    def call
      return unless SiteSetting.bekcan_academic_profile_enabled

      DistributedMutex.synchronize("bekcan_academic_fields_init") do
        ActiveRecord::Base.transaction do
          # 1. Akademik Ünvan Alanı ve Opsiyon Senkronizasyonu
          title_field = UserField.find_or_initialize_by(name: "academic_title")
          
          if title_field.new_record?
            title_field.field_type = "dropdown"
            title_field.description = "user.user_fields.academic_title" # I18n anahtarı
            title_field.editable = true
            title_field.show_on_profile = true
            title_field.show_on_user_card = true
            title_field.save!
          end

          # Ayarlardan gelen güncel unvan listesini al (örn: "prof|assoc_prof")
          configured_titles = SiteSetting.bekcan_academic_titles.split("|").map(&:strip).reject(&:blank?)

          # Yeni seçenekleri ekle
          configured_titles.each do |key|
            UserFieldOption.find_or_create_by!(user_field_id: title_field.id, value: key)
          end

          # Ayarlardan kaldırılan seçenekleri veritabanından temizle
          UserFieldOption.where(user_field_id: title_field.id)
                         .where.not(value: configured_titles)
                         .destroy_all
        end
      end
    rescue => e
      Rails.logger.error("Academic Field Builder Error: #{e.message}")
    end
  end
end