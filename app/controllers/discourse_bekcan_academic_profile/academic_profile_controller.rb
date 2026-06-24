module ::DiscourseBekcanAcademicProfile
  class AcademicProfileController < ::Admin::AdminController
    def index
      titles = SiteSetting.bekcan_academic_titles.split("|").map(&:strip).reject(&:blank?)
      mappings = PluginStore.get("bekcan_academic", "group_mappings") || {}
      render json: { status: "active", titles: titles, mappings: mappings }
    end

    def sync
      ::DiscourseBekcanAcademicProfile::UserFieldBuilder.new.call
      mappings = params[:mappings] || {}
      # Veri güvenliği: sadece tamsayıları işle
      clean_mappings = mappings.transform_values { |v| Array(v).map(&:to_i).reject(&:zero?) }
      PluginStore.set("bekcan_academic", "group_mappings", clean_mappings)
      render json: success_json
    end
  end
end