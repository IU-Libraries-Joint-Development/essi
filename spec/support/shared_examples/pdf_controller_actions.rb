RSpec.shared_examples 'pdf controller actions' do |resource_symbol|

  describe 'when logged in', :clean do
    let(:main_app) { Rails.application.routes.url_helpers }
    let(:user) { FactoryBot.create(:user) }
    let(:resource) { FactoryBot.create(resource_symbol, user: user, title: ['Dummy Title'], pdf_state: 'NOT downloadable') }
  
    describe '#pdf' do
      context 'without authorization' do
        before(:each) do
          get :pdf, params: { id: resource.id }
        end
        it 'redirects to the resource' do
          show_page = main_app.send("hyrax_#{resource_symbol}_path", resource, locale: 'en')
          expect(response).to redirect_to show_page
        end
        it 'displays an alert' do
          expect(flash[:alert]).to match /You do not have access to download this PDF/i
        end
      end
    end
  end
end
