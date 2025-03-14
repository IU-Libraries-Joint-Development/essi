require 'rails_helper'

RSpec.describe 'Catalog Search', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let!(:work1) { FactoryBot.create(:paged_resource, title: ["The Moomins and the Great Flood"], user: user) }
  let!(:work2) { FactoryBot.create(:paged_resource, title: ["The Moomin Family"], user: user) }
  let!(:work3) { FactoryBot.create(:paged_resource, user: user) }

  describe 'GET /catalog' do

    it 'should return search results' do
      get "/catalog?search_field=all_fields&q=Moomin"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include work1.title.first
      expect(response.body).to include work2.title.first
      expect(response.body).not_to include work3.title.first
    end
  end
end
