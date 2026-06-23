# name: discourse-bekcan-academic-profile
# about: Academic profile fields for users
# version: 0.1
# authors: Can Bekcan
# url: https://github.com/canbekcan/discourse-bekcan-academic-profile

after_initialize do
  # Apply x02d rule: Explicit array structure for sub_fields instead of straight symbol
  add_permitted_user_update_param(:academic_title)
  add_permitted_user_update_param(:main_field)
  add_permitted_user_update_param(sub_fields: [])
  add_permitted_user_update_param(:orcid_id)

  add_to_serializer(:user, :academic_title) { object.academic_profile_field&.academic_title }
  add_to_serializer(:user, :main_field) { object.academic_profile_field&.main_field }
  add_to_serializer(:user, :sub_fields) { object.academic_profile_field&.sub_fields }
  add_to_serializer(:current_user, :orcid_id) { object.academic_profile_field&.orcid_id }

  DiscourseEvent.on(:after_auth) do |authenticator, auth_result|
    if authenticator.name == 'oidc' && auth_result.extra_data[:orcid_id]
      if user = auth_result.user
        field = user.academic_profile_field || user.build_academic_profile_field
        field.update(orcid_id: auth_result.extra_data[:orcid_id])
      end
    end
  end
end