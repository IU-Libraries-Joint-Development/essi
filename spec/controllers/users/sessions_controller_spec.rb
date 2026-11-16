require 'rails_helper'

describe Users::SessionsController do
  before do
    # Needed to test devise controller actions directly
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  # destroy is used to sign out to user
  describe 'destroy' do
    context 'when signed in' do
      let(:user) { FactoryBot.create(:user) }
      let(:token) { AuthToken.fetch_token_for(user.email) }
      before { sign_in user }

      it 'are unset when signing out' do
        get 'sign_in_autoclose' # Used here because we need some request to set the cookie
        expect(cookies['iiif-auth']).to eq token.id
        get 'destroy'
        expect(cookies['iiif-auth']).to eq nil
      end
    end
  end

  describe 'sign_in_autoclose' do
    it 'renders js to close the window' do
      get 'sign_in_autoclose'
      expect(response.body).to eq "<html><head><script>window.close();</script></head><body></body></html>"
    end
  end
end
