# Generated via
#  `rails generate hyrax:work PagedResource`
require 'rails_helper'

RSpec.describe PagedResource do

  include_examples "MARC Relators"
  include_examples "PagedResource Properties"
  include_examples "ExtraLockable Behaviors" do
    let(:curation_concern) { FactoryBot.create(:paged_resource) }
  end
  include_examples "round trip update behaviors" do
    let(:new_work) { FactoryBot.build(:paged_resource) }
    let(:work) { FactoryBot.create(:paged_resource) }
  end

  describe '#ocr_searchable?' do
    let(:work) { described_class.new(ocr_state: nil) }

    context "when ocr_state is searchable" do
      it 'is searchable' do
        work.ocr_state = 'searchable'
        expect(work).to be_ocr_searchable
      end
    end

    context "when ocr_state is suppressed" do
      it 'is not searchable' do
        work.ocr_state = 'suppressed'
        expect(work).not_to be_ocr_searchable
      end
    end

    context "when ocr_state is nil" do
      it 'is not searchable' do
        expect(work).not_to be_ocr_searchable
      end
    end
  end
end
