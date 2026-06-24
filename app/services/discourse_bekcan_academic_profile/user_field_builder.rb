# app/services/discourse_bekcan_academic_profile/user_field_builder.rb
# frozen_string_literal: true

module DiscourseBekcanAcademicProfile
  class UserFieldBuilder
    def self.build!
      # Enforce DistributedMutex as required by operational memory
      DistributedMutex.synchronize("bekcan_academic_title_field_lock") do
        # 1. Use an invariant machine key for the database query, NEVER a localized string
        field = UserField.find_or_initialize_by(name: 'academic_title')

        # 2. Assign standard metadata
        field.description = I18n.t("bekcan_academic_profile.user_field.description", default: "Academic Title")
        field.field_type = 'dropdown'
        field.editable = true
        field.required = true
        field.show_on_profile = true
        field.show_on_user_card = true

        # 3. Only execute a database transaction if attributes were newly initialized or modified
        field.save! if field.changed?
      end
    end
  end
end