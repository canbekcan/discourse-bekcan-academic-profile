# name: discourse-bekcan-academic-profile
# about: Academic profile fields for users
# version: 0.1
# authors: Can Bekcan
# url: https://github.com/canbekcan/discourse-bekcan-academic-profile

after_initialize do
  # CORRECT: Register params via the registry, not via method call
  [:academic_title, :main_field, :orcid_id].each do |p|
    DiscoursePluginRegistry.permitted_user_update_params << p
  end
  DiscoursePluginRegistry.permitted_user_update_params << { sub_fields: [] }
end