require 'rails_helper'


RSpec.describe ESSI::GeneratePdfService do
  let(:resource) { create(:paged_resource) }
  let(:service) { described_class.new(resource) }

  describe '#generate' do
    it 'generates a pdf document' do

    end

    it 'returns the path and file name of the generated pdf document' do
      expect(service.generate).to eq()
    end
  end
end
