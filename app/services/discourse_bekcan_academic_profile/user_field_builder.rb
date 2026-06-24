module ::DiscourseBekcanAcademicProfile
  class UserFieldBuilder
    def call
      return unless SiteSetting.bekcan_academic_profile_enabled

      DistributedMutex.synchronize("bekcan_academic_fields_init") do
        ActiveRecord::Base.transaction do
          
          # 1. Akademik Ünvan (Diğer eklentileri çökertmemek için find_or_initialize_by)
          title_field = UserField.find_or_initialize_by(name: "academic_title")
          title_field.field_type = "dropdown"
          title_field.description = "academic_title" # İngilizce veya Türkçe UI tarafında çevrilecek
          title_field.editable = true
          title_field.show_on_profile = true
          title_field.show_on_user_card = true
          title_field.save!

          configured_titles = SiteSetting.bekcan_academic_titles.split("|").map(&:strip).reject(&:blank?)
          configured_titles.each { |key| UserFieldOption.find_or_create_by!(user_field_id: title_field.id, value: key) }
          UserFieldOption.where(user_field_id: title_field.id).each { |opt| opt.destroy! unless configured_titles.include?(opt.value) }

          # 2. Akademik Alan
          field_acc = UserField.find_or_initialize_by(name: "academic_field")
          field_acc.field_type = "dropdown"
          field_acc.description = "academic_field"
          field_acc.editable = true
          field_acc.show_on_profile = true
          field_acc.save!

          # 3. Bilim Dalları
          field_disc = UserField.find_or_initialize_by(name: "scientific_disciplines")
          field_disc.field_type = "text"
          field_disc.description = "scientific_disciplines"
          field_disc.editable = true
          field_disc.show_on_profile = true
          field_disc.save!

        end
      end
    rescue StandardError => e
      Discourse.warn_exception(e, message: "Academic fields build failed.")
    end
  end
end