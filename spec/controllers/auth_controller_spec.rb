require 'rails_helper'

describe AuthController do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }
  let(:auth_token) { AuthToken.fetch_token_for(user.email) }

  let(:public_image) { FactoryBot.create(:file_set, :public, content_location: "pub-#{rand 1e9}") }
  let(:private_image) { FactoryBot.create(:file_set, user: user, content_location: "priv-#{rand 1e9}") }
  let(:other_private_image) { FactoryBot.create(:file_set, user: other_user, content_location: "priv-#{rand 1e9}") }

  let(:public_content_location) { Base64.urlsafe_encode64(public_image.content_location) }
  let(:private_content_location) { Base64.urlsafe_encode64(private_image.content_location) }
  let(:other_private_content_location) { Base64.urlsafe_encode64(other_private_image.content_location) }

  describe '#token' do
    context 'as anonymous user' do
      it 'allows public access' do
        get(:token, params: { id: public_content_location })
        expect(response).to have_http_status(:ok)
      end

      it 'rejects private access' do
        get(:token, params: { id: private_content_location })
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'as logged in user' do
      before do
        sign_in(user)
      end

      it 'allows public access' do
        get(:token, params: { id: public_content_location })
        expect(response).to have_http_status(:ok)
      end

      it 'allows private access' do
        get(:token, params: { id: private_content_location })
        expect(response).to have_http_status(:ok)
        expect(response.body).to include auth_token.id
      end

      it 'rejects access to other private resources' do
        get(:token, params: { id: other_private_content_location })
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe '#probe' do
    it 'allows public access' do
      get(:probe, params: { id: public_content_location })
      expect(response).to have_http_status(:ok)
    end

    it 'rejects private access' do
      get(:probe, params: { id: private_content_location })
      expect(response).to have_http_status(:unauthorized)
    end

    context 'with bearer token' do
      before do
        request.headers["Authorization"] = "Bearer #{auth_token.id}"
      end

      it 'allows public access' do
        get(:probe, params: { id: public_content_location })
        expect(response).to have_http_status(:ok)
      end

      it 'allows private access' do
        get(:probe, params: { id: private_content_location })
        expect(response).to have_http_status(:ok)
      end

      it 'rejects access to other private resources' do
        get(:probe, params: { id: other_private_content_location })
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end