module ::DiscourseBekcanAcademicProfile
  class AcademicProfileController < ::Admin::AdminController
    requires_plugin "discourse-bekcan-academic-profile"

    def index
      titles = SiteSetting.bekcan_academic_titles.split("|").map(&:strip).reject(&:blank?)
      mappings = PluginStore.get("bekcan_academic", "group_mappings") || {}
      render json: { status: "active", titles: titles, mappings: mappings }
    end

    def sync
      ::DiscourseBekcanAcademicProfile::UserFieldBuilder.new.call
      mappings = params[:mappings] || {}
      clean_mappings = {}
      mappings.each { |title, group_ids| clean_mappings[title] = group_ids.map(&:to_i).reject(&:zero?) }
      PluginStore.set("bekcan_academic", "group_mappings", clean_mappings)
      render json: success_json
    rescue StandardError => e
      render_json_error(e.message)
    end
  end
end