require 'rails_helper'

describe CatalogController do
  describe 'saved searches' do
    it 'does not save searches' do
      expect { get 'index', params: { q: 'test' } }.not_to change { Search.count }
    end
  end

  # Any ApplicationController descendant should pass this spec,
  # CatalogController is a good test candidate since users will be frequent visitors,
  # and has lots of imported behaviors potentially interfering.
  describe 'iiif auth cookies' do
    context 'when signed in' do
      let(:user) { FactoryBot.create(:user) }
      let(:token) { AuthToken.fetch_token_for(user.email) }
      before { sign_in user }

      it 'are set' do
        get 'index'
        expect(cookies['iiif-auth']).to eq token.id
      end
    end

    context 'when anonymous' do
      it 'are not set' do
        get 'index'
        expect(cookies['iiif-auth']).to eq nil
      end
    end
  end
end
