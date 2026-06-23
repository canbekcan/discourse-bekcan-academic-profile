module ::DiscourseBekcanAcademicProfile
  class AcademicProfileController < ::Admin::AdminController
    requires_plugin "discourse-bekcan-academic-profile"

    def index
      render json: {
        status: "active",
        current_titles: SiteSetting.bekcan_academic_titles.split("|").map(&:strip)
      }
    end

    def sync
      # İş mantığı servisini çağırarak sadece yetkilendirilmiş akademik ünvanların veritabanında kalmasını sağlar
      ::DiscourseBekcanAcademicProfile::UserFieldBuilder.new.call
      render json: success_json
    rescue StandardError => e
      render_json_error(e.message)
    end
  end
end