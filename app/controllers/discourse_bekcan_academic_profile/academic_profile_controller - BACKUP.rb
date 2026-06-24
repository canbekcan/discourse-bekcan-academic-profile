# frozen_string_literal: true

module ::DiscourseBekcanAcademicProfile
  class AcademicProfileController < ::Admin::AdminController
    requires_plugin "discourse_bekcan_academic_profile"

    def index
      # Retrieve current state from SiteSettings and PluginStore
      render json: {
        titles: SiteSetting.bekcan_academic_titles.split("|").map(&:strip).reject(&:blank?),
        mappings: PluginStore.get("bekcan_academic_profile", "group_mappings") || {},
        groups: Group.select(:id, :name).map { |g| { id: g.id, name: g.name } }
      }

      # Use the Serializer to format the output
      render_serialized(data, ::DiscourseBekcanAcademicProfile::AcademicProfileSerializer)
    end

    def sync
      # Validate parameters using a standard Contract pattern (Step 06)
      params.require(:mappings)
      
      # Execute the business logic via the dedicated Service Object
      # This ensures thread-safety via DistributedMutex and transactional integrity
      result = ::DiscourseBekcanAcademicProfile::AssignAcademicGroups.call(
        mappings: params[:mappings]
      )

      if result.success?
        render json: success_json
      else
        render json: { errors: result.errors }, status: :unprocessable_entity
      end
    end
  end
end