module ::DiscourseBekcanAcademicProfile
  class AcademicProfileController < ::Admin::AdminController
    requires_plugin "discourse-bekcan-academic-profile"

    def index
      titles = SiteSetting.bekcan_academic_titles.split("|").map(&:strip).reject(&:blank?)
      # Eşleşmeleri PluginStore'dan çek (Örn: {"Profesör" => [1, 4], "Doçent" => [2]})
      mappings = PluginStore.get("bekcan_academic", "group_mappings") || {}

      render json: {
        status: "active",
        titles: titles,
        mappings: mappings
      }
    end

    def sync
      # 1. User Field seçeneklerini senkronize et
      ::DiscourseBekcanAcademicProfile::UserFieldBuilder.new.call
      
      # 2. Ünvan -> Grup eşleşmelerini kaydet
      mappings = params[:mappings] || {}
      clean_mappings = {}
      
      mappings.each do |title, group_ids|
        # Gelen array içerisindeki ID'leri güvenli tamsayılara çevir
        clean_mappings[title] = group_ids.map(&:to_i).reject(&:zero?)
      end
      
      PluginStore.set("bekcan_academic", "group_mappings", clean_mappings)

      render json: success_json
    rescue StandardError => e
      render_json_error(e.message)
    end
  end
end