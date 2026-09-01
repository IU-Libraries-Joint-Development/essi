require 'rails_helper'

describe BrowseEverythingController do
  routes { BrowseEverything::Engine.routes }

  let(:base_path) { BrowseEverything.config[:file_system][:home] }
  let(:admin) { create(:admin) }

  describe '#show' do
    context 'scoped dropboxes' do
      let(:admin_set_id) { 'admin_set_id' }
      let(:scoped_dropbox_path) { '/path/to/scoped/dropbox' }
      let(:dropbox_map) { { admin_set_id => scoped_dropbox_path } }

      before do
        allow(controller).to receive(:dropbox_map).and_return(dropbox_map)
      end

      it 'scopes dropbox' do
        get :show, params: { context: admin_set_id, "provider"=>"file_system" }, xhr: true
        expect(assigns(:browser).providers[:file_system].config[:home]).to eq scoped_dropbox_path
      end

      context 'when admin' do
        it 'does not scope' do
          sign_in admin
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
