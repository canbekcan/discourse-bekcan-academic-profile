# name: discourse-bekcan-academic-profile
# about: Academic profile fields for users
# version: 0.1
# authors: Can Bekcan
# url: https://github.com/canbekcan/discourse-bekcan-academic-profile

after_initialize do
  [:academic_title, :main_field, :orcid_id].each { |p| DiscoursePluginRegistry.permitted_user_update_params << p }
  DiscoursePluginRegistry.permitted_user_update_params << { sub_fields: [] }

  add_to_serializer(:user, :academic_title) { object.academic_profile_field&.academic_title }
  add_to_serializer(:user, :main_field) { object.academic_profile_field&.main_field }
  add_to_serializer(:user, :sub_fields) { object.academic_profile_field&.sub_fields }
  add_to_serializer(:current_user, :orcid_id) { object.academic_profile_field&.orcid_id }
end