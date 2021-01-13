RSpec.shared_examples 'update metadata' do |resource_symbol|

  describe 'when logged in', :clean do
    let(:user) { FactoryBot.create(:user) }
    let(:resource) { FactoryBot.create(resource_symbol, user: user, title: ['Dummy Title']) }
    let(:reloaded) { resource.reload }
  
    before { sign_in user }
  
    describe '#update' do
      let(:static_attributes) { { title: ['Updated Title'] } }

      context 'with valid attributes' do
        it 'updates the record' do
          perform_enqueued_jobs do
            patch :update,
                  params: { id: resource.id,
                            resource_symbol => static_attributes }
          end
          expect(reloaded.title).to eq ['Updated Title']
        end
      end
    end
  end
end
