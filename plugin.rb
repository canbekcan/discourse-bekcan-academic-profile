# frozen_string_literal: true

# name: discourse-bekcan-academic-profile
# about: Manages academic profiles and automated group assignments via Discourse user fields.
# version: 0.1.0
# authors: BEKCAN
# url: https://github.com/canbekcan/discourse-bekcan-academic-profile
# minimum_discourse_version: 3.2.0.beta1

enabled_site_setting :bekcan_academic_profile_enabled

module ::DiscourseBekcanAcademicProfile
  PLUGIN_NAME = "discourse-bekcan-academic-profile"
end

require_relative "lib/discourse_bekcan_academic_profile/engine"

after_initialize do
  # Safely mount engine routes to the main Discourse application
  Discourse::Application.routes.append do
    mount ::DiscourseBekcanAcademicProfile::Engine, at: "/admin/plugins/academic-profile"
  end

  # Inject the admin navigation link
  add_admin_route("bekcan_academic_profile.title", "academic-profile")
end