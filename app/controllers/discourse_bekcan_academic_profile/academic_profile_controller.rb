# frozen_string_literal: true

module ::DiscourseBekcanAcademicProfile
  class AcademicProfileController < ::Admin::AdminController
    requires_plugin DiscourseBekcanAcademicProfile::PLUGIN_NAME

    def index
      render_serialized(
        {
          titles: SiteSetting.bekcan_academic_titles.split('|'),
          mappings: PluginStore.get(DiscourseBekcanAcademicProfile::PLUGIN_NAME, 'group_mappings') || [],
          groups: Group.all.select(:id, :name)
        },
        AcademicProfileSerializer,
        root: false
      )
    end

    def sync
      # Delegate business logic strictly to the Service Object
      # result = AssignAcademicGroups.call(params)
      
      render json: { success: true }
    end
  end
end