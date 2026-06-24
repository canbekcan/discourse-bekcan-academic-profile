module ::DiscourseBekcanAcademicProfile
  class UserFieldBuilder
    def call
      return unless SiteSetting.bekcan_academic_profile_enabled

      # Sistem dilini al (tr_TR)
      locale = SiteSetting.default_locale

      DistributedMutex.synchronize("bekcan_academic_fields_init") do
        ActiveRecord::Base.transaction do
          
          # 1. Akademik Ünvan (Eski adıyla bul veya lokalize adıyla bul, günülle)
          title_name = I18n.t("bekcan_academic_profile.user_fields.academic_title_name", locale: locale)
          title_field = UserField.find_by(name: "academic_title") || UserField.find_by(name: title_name) || UserField.new
          
          title_field.update!(
            name: title_name,
            field_type: "dropdown",
            description: I18n.t("bekcan_academic_profile.user_fields.academic_title_desc", locale: locale),
            editable: true,
            show_on_profile: true,
            show_on_user_card: true
          )

          configured_titles = SiteSetting.bekcan_academic_titles.split("|").map(&:strip).reject(&:blank?)
          configured_titles.each { |t_name| UserFieldOption.find_or_create_by!(user_field_id: title_field.id, value: t_name) }
          UserFieldOption.where(user_field_id: title_field.id).each { |opt| opt.destroy! unless configured_titles.include?(opt.value) }

          # 2. Akademik Alan
          field_name = I18n.t("bekcan_academic_profile.user_fields.academic_field_name", locale: locale)
          acc_field = UserField.find_by(name: "academic_field") || UserField.find_by(name: field_name) || UserField.new
          acc_field.update!(
            name: field_name,
            field_type: "dropdown",
            description: I18n.t("bekcan_academic_profile.user_fields.academic_field_desc", locale: locale),
            editable: true,
            show_on_profile: true
          )

          # 3. Bilim Dalları
          disc_name = I18n.t("bekcan_academic_profile.user_fields.scientific_disciplines_name", locale: locale)
          disc_field = UserField.find_by(name: "scientific_disciplines") || UserField.find_by(name: disc_name) || UserField.new
          disc_field.update!(
            name: disc_name,
            field_type: "text",
            description: I18n.t("bekcan_academic_profile.user_fields.scientific_disciplines_desc", locale: locale),
            editable: true,
            show_on_profile: true
          )

        end
      end
    rescue StandardError => e
      Discourse.warn_exception(e, message: "Academic fields build failed.")
    end
  end
end