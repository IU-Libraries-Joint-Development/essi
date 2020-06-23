# Generated via
#  `rails generate hyrax:work PagedResource`
include Warden::Test::Helpers
    #  click_link "Add new work"
#require 'rails_helper'
#include Warden::Test::Helpers
#include ActiveJob::TestHelper
#
## NOTE: If you generated more than one work, you have to set "js: true"
#RSpec.feature 'Download a PagedResource PDF', type: :system, js: true do
#  context 'a logged in user', clean: true do
#    let(:user) do
#      FactoryBot.create :user
#    end
#    let(:paged_resource) { create :paged_resource_with_one_image, user: user }
#    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
#    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
#    let(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }
#
#    before do
#      # Create a single action that can be taken
#      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)
#
#      # Grant the user access to deposit into the admin set.
#      Hyrax::PermissionTemplateAccess.create!(
#        permission_template_id: permission_template.id,
#        agent_type: 'user',
#        agent_id: user.user_key,
#        access: 'deposit'
#      )
#      ESSI.config[:essi][:allow_pdf_download] = true
#      # Ensure empty requirement for ldap group authorization
#      allow(ESSI.config[:authorized_ldap_groups]).to receive(:blank?).and_return(true)
#      login_as user
#    end
#
#    def wait_until_uv_loads
#      page.has_css?('button.download')
#    end
#
#    scenario do
#      visit polymorphic_path [paged_resource]
#
#      wait_until_uv_loads
#      byebug
#      find('.download').click
#      choose('Download as PDF (pdf)')
#      click('Download')
#      expect(page).to have_current_path("#{polymorphic_path [paged_resource]}/pdf")
#
#  end
#end
