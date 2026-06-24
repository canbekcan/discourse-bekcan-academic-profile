# frozen_string_literal: true
module ::DiscourseBekcanAcademicProfile
  class AcademicProfileController < ::Admin::AdminController
    requires_plugin "discourse-bekcan-academic-profile"

    def index
      titles = SiteSetting.bekcan_academic_titles.split("|").map(&:strip).reject(&:blank?)
      mappings = PluginStore.get("bekcan_academic", "group_mappings") || {}
      # Admin paneline grupları gönderiyoruz
      groups = Group.select(:id, :name).map { |g| { id: g.id, name: g.name } }
      render json: { titles: titles, mappings: mappings, groups: groups }
    end

    def sync
      ::DiscourseBekcanAcademicProfile::UserFieldBuilder.new.call
      mappings = params[:mappings] || {}
      clean_mappings = mappings.transform_values { |v| Array(v).map(&:to_i).reject(&:zero?) }
      PluginStore.set("bekcan_academic", "group_mappings", clean_mappings)
      render json: success_json
    end
  end
end