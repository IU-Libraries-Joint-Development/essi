# Generated via
#  `rails generate hyrax:work PagedResource`
require 'rails_helper'
include Warden::Test::Helpers
include ActiveJob::TestHelper

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Download a PagedResource PDF', type: :system, js: true do
  context 'a logged in user', clean: true do
    let(:user) do
      FactoryBot.create :admin
    end
    let(:paged_resource) { create :paged_resource_with_one_image, user: user }

    before do
      ESSI.config[:essi][:allow_pdf_download] = true
      login_as user
    end

    def wait_until_uv_loads
      page.has_css?('button.download')
    end

    #scenario do
    #  visit polymorphic_path [paged_resource]

    #  wait_until_uv_loads
    #  find('.download').click
    #  choose('Download as PDF (pdf)')
    #  click('Download')
    #  expect(page).to have_current_path("#{polymorphic_path [paged_resource]}/pdf")

    #  #TODO: Add Coverpage Specs 
    #end
  end
end
