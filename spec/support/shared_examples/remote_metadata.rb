RSpec.shared_examples 'update metadata remotely' do |resource_symbol|

  describe 'when logged in', :clean do
    let(:user) { FactoryBot.create(:user) }
    let(:resource) { FactoryBot.create(resource_symbol,
                                       user: user,
                                       title: ['Dummy Title'],
                                       source_metadata_identifier: nil) }
    let(:reloaded) { resource.reload }

    before { sign_in user }

    describe '#update' do
      let(:static_attributes) {
        {
          title: ['Updated Title'],
          source_metadata_identifier: 'BHR9405'
        }
      }
      let(:invalid_identifier_attributes) {
        {
          title: ['Updated Title'],
          source_metadata_identifier: 'BHR9405%INVALID$CHARACTERS'
        }
      }
      let(:no_results_identifier_attributes) {
        {
            title: ['Updated Title'],
            source_metadata_identifier: 'VAC1741-00231'
        }
      }

      context 'without remote refresh flag' do
        it 'updates the record but does not refresh the external metadata' do
          perform_enqueued_jobs do
            patch :update,
                 params: { id: resource.id,
                           resource_symbol => static_attributes }
          end
          expect(reloaded.title).to eq ['Updated Title']
        end
      end
  
      context 'with remote refresh flag', vcr: { cassette_name: 'bibdata', record: :new_episodes } do
        context 'with an invalid identifier' do
          it 'updates the record' do
            perform_enqueued_jobs do
              patch :update,
                   params: { id: resource.id,
                             resource_symbol => invalid_identifier_attributes,
                             refresh_remote_metadata: true }
            end
            expect(reloaded.title).to eq ['Updated Title']
          end
          it 'flashes an alert about not refreshing the external metadata' do
            perform_enqueued_jobs do
              patch :update,
                 params: { id: resource.id,
                           resource_symbol => invalid_identifier_attributes,
                           refresh_remote_metadata: true }
            end
            expect(flash[:alert]).to match I18n.t('services.remote_metadata.invalid_identifier')
            expect(flash[:alert]).to match I18n.t('services.remote_metadata.validation')
          end
        end
        context 'with a valid, non-matching source metadata ID' do
          it 'updates the record' do
            perform_enqueued_jobs do
              patch :update,
                  params: { id: resource.id,
                            resource_symbol => no_results_identifier_attributes,
                            refresh_remote_metadata: true }
            end
            expect(reloaded.title).to eq ['Updated Title']
          end
          it 'flashes an alert about no results found' do
            perform_enqueued_jobs do
              patch :update,
                  params: { id: resource.id,
                            resource_symbol => no_results_identifier_attributes,
                            refresh_remote_metadata: true }
            end
            expect(flash[:alert]).to match I18n.t('services.remote_metadata.no_results')
          end
        end
        context 'with a valid, matching source metadata ID' do
          it 'updates the record and refreshes the external metadata' do
            perform_enqueued_jobs do
              patch :update,
                 params: { id: resource.id,
                           resource_symbol => static_attributes,
                           refresh_remote_metadata: true }
            end
            expect(reloaded.title).to eq ['Fontane di Roma ; poema sinfonico per orchestra']
            expect(reloaded.source_metadata_identifier).to eq 'BHR9405'
          end
        end
      end
    end
  end
end
