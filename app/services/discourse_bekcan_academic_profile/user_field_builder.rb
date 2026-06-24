# frozen_string_literal: true
module ::DiscourseAcademicProfile
  class UserFieldBuilder
    def call
      return unless SiteSetting.bekcan_academic_profile_enabled

      # Veritabanında sabit kodlar tutulur, çeviriler client/server yml dosyalarından alınır
      fields_config = {
        "academic_title" => { type: "dropdown", desc: "bekcan_academic_profile.user_fields.academic_title_desc" },
        "academic_field" => { type: "dropdown", desc: "bekcan_academic_profile.user_fields.academic_field_desc" },
        "scientific_disciplines" => { type: "text", desc: "bekcan_academic_profile.user_fields.scientific_disciplines_desc" }
      }

      DistributedMutex.synchronize("bekcan_academic_fields_init") do
        ActiveRecord::Base.transaction do
          fields_config.each do |key, config|
            field = UserField.find_or_initialize_by(name: key)
            if field.new_record?
              field.field_type = config[:type]
              field.description = config[:desc]
              field.editable = true
              field.show_on_profile = true
              field.show_on_user_card = true
              field.save!
            end
          end

          # Ünvan seçeneklerini güncelle
          title_field = UserField.find_by(name: "academic_title")
          titles = SiteSetting.bekcan_academic_titles.split("|").map(&:strip).reject(&:blank?)
          
          titles.each { |key| UserFieldOption.find_or_create_by!(user_field_id: title_field.id, value: key) }
          UserFieldOption.where(user_field_id: title_field.id).where.not(value: titles).destroy_all
        end
      end
    end
  end
end