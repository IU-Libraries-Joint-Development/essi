require 'rails_helper'

describe BrowseEverythingController, :clean_repo do
  routes { BrowseEverything::Engine.routes }

  let(:base_path) { BrowseEverything.config[:file_system][:home] }
  let(:user) { create(:user) }
  let(:depositor) { create(:user) }
  let(:admin) { create(:admin) }

  let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
  let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
  let(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

  describe 'security' do
    context 'with unauthenticated user' do
      it 'returns 401 unauthorized' do
        expect(get :index).not_to be_successful
        expect(get :index, xhr: true).not_to be_successful
        expect(get :show, params: { provider: 'file_system' }).not_to be_successful
        expect(get :show, params: { provider: 'file_system' }, xhr: true).not_to be_successful
        expect(get :show, params: { provider: 'file_system', context: 'abcd1234' }, xhr: true).not_to be_successful
        expect(get :show, params: { provider: 'file_system', context: 'abcd1234', path: 'subfolder' }, xhr: true).not_to be_successful
        expect(get :auth).not_to be_successful
        expect(get :auth, xhr: true).not_to be_successful
        expect(get :resolve).not_to be_successful
        expect(get :resolve, xhr: true).not_to be_successful
      end
    end

    context 'with end-user' do
      before { sign_in user }

      it 'returns 401 unauthorized' do
        expect(get :index).not_to be_successful
        expect(get :index, xhr: true).not_to be_successful
        expect(get :show, params: { provider: 'file_system' }).not_to be_successful
        expect(get :show, params: { provider: 'file_system' }, xhr: true).not_to be_successful
        expect(get :show, params: { provider: 'file_system', context: 'abcd1234' }, xhr: true).not_to be_successful
        expect(get :show, params: { provider: 'file_system', context: 'abcd1234', path: 'subfolder' }, xhr: true).not_to be_successful
        expect(get :auth).not_to be_successful
        expect(get :auth, xhr: true).not_to be_successful
        expect(get :resolve).not_to be_successful
        expect(get :resolve, xhr: true).not_to be_successful
      end
    end

    context 'with admin set member' do
      before do
        # Create a single action that can be taken
        Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)

        # Grant the user access to deposit into the admin set.
        Hyrax::PermissionTemplateAccess.create!(
          permission_template_id: permission_template.id,
          agent_type: 'user',
          agent_id: user.user_key,
          access: 'deposit'
        )
        # Ensure empty requirement for ldap group authorization
        allow(ESSI.config[:authorized_ldap_groups]).to receive(:blank?).and_return(true)
        sign_in user
      end

      it 'responds' do
        expect(get :index).to be_successful
        expect(get :index, xhr: true).to be_successful
        #expect(get :show, params: { provider: 'file_system' }).to be_successful # raises ActionView::MissingTemplate
        expect(get :show, params: { provider: 'file_system' }, xhr: true).to be_successful
        expect(get :show, params: { provider: 'file_system', context: admin_set_id}, xhr: true).to be_successful
        expect(get :show, params: { provider: 'file_system', context: admin_set_id, path: 'subfolder' }, xhr: true).to be_successful
        expect(get :auth).to be_successful
        expect(get :auth, xhr: true).to be_successful
        #expect(get :resolve).to be_successful # raises ActionView::MissingTemplate
        expect(get :resolve, format: :json, xhr: true).to be_successful
      end
    end
  end

  describe '#show' do
    context 'scoped dropboxes' do
      let(:scoped_dropbox_path) { '/path/to/scoped/dropbox' }
      let(:dropbox_map) { { admin_set_id => scoped_dropbox_path } }

      before do
        # Create a single action that can be taken
        Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)

        # Grant the user access to deposit into the admin set.
        Hyrax::PermissionTemplateAccess.create!(
          permission_template_id: permission_template.id,
          agent_type: 'user',
          agent_id: user.user_key,
          access: 'deposit'
        )
        # Ensure empty requirement for ldap group authorization
        allow(ESSI.config[:authorized_ldap_groups]).to receive(:blank?).and_return(true)
        sign_in user

        allow(controller).to receive(:dropbox_map).and_return(dropbox_map)
      end

      it 'scopes dropbox' do
        get :show, params: { context: admin_set_id, "provider"=>"file_system" }, xhr: true
        expect(assigns(:browser).providers[:file_system].config[:home]).to eq scoped_dropbox_path
      end

      context 'when admin' do
        let(:user) { admin }
        it 'does not scope' do
          get :show, params: { context: admin_set_id, "provider"=>"file_system" }, xhr: true
          expect(assigns(:browser).providers[:file_system].config[:home]).to eq base_path
        end
      end

      context 'when not in map' do
        it 'does not scope' do
          get :show, params: { context: 'different-admin-id', "provider"=>"file_system" }, xhr: true
          expect(assigns(:browser).providers[:file_system].config[:home]).to eq base_path
        end
      end

      context 'when error reading config' do
        before do
          allow(controller).to receive(:dropbox_map).and_call_original
          allow(YAML).to receive(:load_file).and_raise(Errno::ENOENT)
        end

        it 'does not scope' do
          get :show, params: { context: 'different-admin-id', "provider"=>"file_system" }, xhr: true
          expect(assigns(:browser).providers[:file_system].config[:home]).to eq base_path
        end
      end
    end
  end
end
