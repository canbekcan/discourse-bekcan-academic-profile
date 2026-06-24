# frozen_string_literal: true

module PageObjects
  module Pages
    class AdminAcademicPanel < PageObjects::Pages::Base
      def visit_page
        visit "/admin/plugins/academic-profile"
      end

      def sync_mappings(mappings)
        # Using standard Discourse SelectKit selectors
        fill_in_input_field("group_mappings", mappings)
        click_button "Sync"
      end
    end
  end
end