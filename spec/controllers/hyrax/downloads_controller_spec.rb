# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::DownloadsController do
  routes { Hyrax::Engine.routes }

  let(:user) { FactoryBot.create(:user) }
  let(:resource) { FactoryBot.create(:file_set, user: user, title: ['Ext File'], content_location: content_location) }
  let(:content_location) { 's3://localhost:9000/essi-test/ext-store/12/34/ab/cd/1234abcd-original_file.ptif' }
  let(:identifier) { content_location.split('/').last }
  let(:data) { 'test data' }
  let(:ext_store_response) { double('S3 Response', body: StringIO.new(data)) }

  before { sign_in user }

  it 'handles requests for files with s3:// prefixed content location' do
    expect(ESSI.external_storage).to receive(:get).with(identifier)
                                                  .and_return(ext_store_response)
    get :show, params: { id: resource.id }
    expect(response).to be_successful
    expect(response.body).to eq data
  end

end
