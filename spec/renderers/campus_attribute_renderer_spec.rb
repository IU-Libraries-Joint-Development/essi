require 'rails_helper'

RSpec.describe CampusAttributeRenderer do
  let(:code) { 'IUB' }
  let(:label) { 'IU Bloomington' }
  let(:obj) {
    {
      id: code, 
      term: label, 
      active: true,
      url: 'https://www.indiana.edu',
      img_src: 'campuses/iub.jpg',
      img_alt: 'The Sample Gates at IU Bloomington'
    }
  }
  let(:options) { {} }
  subject { described_class.new([code], options) }

  before do
    allow(CampusService).to receive(:find).with(code).and_return(obj)
  end

  describe "#value_html" do
    context "for catalog view" do
      let(:options) { { catalog: true } }
      it "returns a blank string" do
        expect(subject.value_html).to be_blank
      end
    end
    context "for iiif view" do
      it "returns a content string" do
        expect(subject.value_html).not_to be_blank
      end
    end
  end

  describe "#attribute_value_to_html" do
    context "with a campus" do
      it "returns the campus display label" do
        expect(subject.send(:attribute_value_to_html, code)).to eq label
      end
    end
  end
end
