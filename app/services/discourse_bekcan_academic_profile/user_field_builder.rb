# frozen_string_literal: true

module ::DiscourseBekcanAcademicProfile
  class UserFieldBuilder
    def call
      return unless SiteSetting.bekcan_academic_profile_enabled

      # "name" alanları veritabanında anahtardır, asla değiştirilmemelidir.
      # Görünür metinler için description alanına i18n anahtarı atıyoruz.
      fields_config = {
        "academic_title" => { type: "dropdown", desc: "bekcan_academic_profile.user_fields.academic_title_desc" },
        "academic_field" => { type: "dropdown", desc: "bekcan_academic_profile.user_fields.academic_field_desc" },
        "scientific_disciplines" => { type: "text", desc: "bekcan_academic_profile.user_fields.scientific_disciplines_desc" }
      }

      DistributedMutex.synchronize("bekcan_academic_fields_init") do
        ActiveRecord::Base.transaction do
          fields_config.each do |key, config|
            field = UserField.find_or_initialize_by(name: key)
            
            # Eğer alan mevcut değilse (yeni oluşturuluyorsa) değerleri set et
            if field.new_record?
              field.field_type = config[:type]
              field.description = config[:desc]
              field.editable = true
              field.show_on_profile = true
              field.show_on_user_card = true
              field.save!
            end
          end
        end
      end
    rescue => e
      Rails.logger.error("Academic Field Builder Error: #{e.message}")
    end
  end
end