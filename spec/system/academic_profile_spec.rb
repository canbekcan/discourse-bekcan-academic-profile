# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Academic Profile Admin Panel", type: :system do
  fab!(:admin) { Fabricate(:admin) }

  before do
    sign_in(admin)
  end

  it "successfully syncs academic mappings" do
    panel = PageObjects::Pages::AdminAcademicPanel.new
    panel.visit_page
    panel.sync_mappings({ "professor" => "1" })
    
    expect(page).to have_css(".alert-success")
  end
end