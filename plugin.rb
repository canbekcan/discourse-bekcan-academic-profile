# name: discourse-bekcan-academic-profile
# about: Academic profile fields for users
# version: 0.1
# authors: Can Bekcan
# url: https://github.com/canbekcan/discourse-bekcan-academic-profile


after_initialize do
  # Fix: Ensure the class is loaded before use
  require_dependency 'user_custom_field_definition'

  [:academic_title, :main_field, :orcid_id, :sub_fields].each do |field_name|
    # Connect or Create field
    UserCustomFieldDefinition.find_or_create_by(name: field_name.to_s) do |f|
      f.field_type = 'text'
    end
    
    # Whitelist for parameter updates
    register_user_custom_field_key(field_name)
  end

  # Serializers mapping custom fields
  add_to_serializer(:user, :academic_title) { object.custom_fields['academic_title'] }
  add_to_serializer(:user, :main_field) { object.custom_fields['main_field'] }
  add_to_serializer(:user, :sub_fields) { object.custom_fields['sub_fields'] }
  add_to_serializer(:current_user, :orcid_id) { object.custom_fields['orcid_id'] }
end