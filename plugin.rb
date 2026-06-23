# name: discourse-bekcan-academic-profile
# about: Academic profile fields for users
# version: 0.1
# authors: Can Bekcan
# url: https://github.com/canbekcan/discourse-bekcan-academic-profile

after_initialize do
  # Ensure custom user field definitions exist (Admin UI integration)
  [:academic_title, :main_field, :orcid_id].each do |field_name|
    UserCustomFieldDefinition.find_or_create_by(name: field_name.to_s) do |f|
      f.field_type = 'text'
    end
  end

  # Register fields for user updates
  [:academic_title, :main_field, :orcid_id].each do |p|
    DiscoursePluginRegistry.permitted_user_update_params << p
  end
  DiscoursePluginRegistry.permitted_user_update_params << { sub_fields: [] }

  # Serializers now map from the custom_fields hash provided by the User model
  add_to_serializer(:user, :academic_title) { object.custom_fields['academic_title'] }
  add_to_serializer(:user, :main_field) { object.custom_fields['main_field'] }
  add_to_serializer(:user, :sub_fields) { object.custom_fields['sub_fields'] }
  add_to_serializer(:current_user, :orcid_id) { object.custom_fields['orcid_id'] }
end