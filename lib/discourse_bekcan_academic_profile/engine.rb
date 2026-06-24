# frozen_string_literal: true
module ::DiscourseBekcanAcademicProfile
  class Engine < ::Rails::Engine
    engine_name "discourse_bekcan_academic_profile"
    isolate_namespace DiscourseBekcanAcademicProfile
    config.autoload_paths << root.join("lib")
  end
end