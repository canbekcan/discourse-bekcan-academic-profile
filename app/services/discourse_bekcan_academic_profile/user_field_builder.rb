module ::DiscourseBekcanAcademicProfile
  class UserFieldBuilder
    def call
      return unless SiteSetting.bekcan_academic_profile_enabled

      DistributedMutex.synchronize("bekcan_academic_fields_init") do
        ActiveRecord::Base.transaction do
          
          # 1. Akademik Ünvan
          title_field = UserField.find_or_create_by!(name: "academic_title") do |f|
            f.field_type = "dropdown"
            f.name = I18n.t("bekcan_academic_profile.user_fields.academic_title_name")
            f.description = I18n.t("bekcan_academic_profile.user_fields.academic_title_desc")
            f.editable = true
            f.show_on_profile = true
            f.show_on_user_card = true
          end

          configured_titles = SiteSetting.bekcan_academic_titles.split("|").map(&:strip).reject(&:blank?)
          configured_titles.each { |title_name| UserFieldOption.find_or_create_by!(user_field_id: title_field.id, value: title_name) }
          UserFieldOption.where(user_field_id: title_field.id).each { |opt| opt.destroy! unless configured_titles.include?(opt.value) }

          # 2. Akademik Alan
          UserField.find_or_create_by!(name: "academic_field") do |f|
            f.field_type = "dropdown"
            f.name = I18n.t("bekcan_academic_profile.user_fields.academic_field_name")
            f.description = I18n.t("bekcan_academic_profile.user_fields.academic_field_desc")
            f.editable = true
            f.show_on_profile = true
          end

          # 3. Bilim Dalları
          UserField.find_or_create_by!(name: "scientific_disciplines") do |f|
            f.field_type = "text"
            f.name = I18n.t("bekcan_academic_profile.user_fields.scientific_disciplines_name")
            f.description = I18n.t("bekcan_academic_profile.user_fields.scientific_disciplines_desc")
            f.editable = true
            f.show_on_profile = true
          end

        end
      end
    rescue StandardError => e
      Discourse.warn_exception(e, message: "Academic fields build failed.")
    end
  end
end