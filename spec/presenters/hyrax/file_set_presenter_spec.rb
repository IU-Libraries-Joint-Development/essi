require 'rails_helper'

RSpec.describe Hyrax::FileSetPresenter do
  subject { described_class.new(double, double) }

  before do
    sets = ['The Collection', 'Another Collection']
    @snake = 'the_collection'
    @title = 'The Title'
    @url = 'http://university.edu'
    work = double('WorkType', admin_set: sets)
    allow(subject).to receive(:parent).and_return(work)
    @campus_logos = ESSI.config[:essi][:campus_logos]
  end

  context 'When initialized' do
    it '.collection_banner_presenter is available' do
      expect(subject).to respond_to(:collection_banner_presenter)
    end
    it '.campus_logo is available' do
      expect(subject).to respond_to(:campus_logo)
    end
    it '.content_location is available' do
      expect(subject).to respond_to(:content_location)
    end
  end

  context 'When campus_logos is not configured' do
    it '.campus_logo returns false' do
      ESSI.config[:essi][:campus_logos] = nil
      expect(subject.campus_logo).to be false
    end
  end

  context 'When admin_set matches configuration' do
    it '.campus_logo returns configured values' do
      ESSI.config[:essi][:campus_logos][@snake] = { title: @title, url: @url }
      expect(subject.campus_logo).to include(@title)
      expect(subject.campus_logo).to include(@url)
    end
  end

  after do
    ESSI.config[:essi][:campus_logos] = @campus_logos
  end

  describe "#ocr_file?" do
    context "when OCR file is absent" do
      before { allow(subject).to receive(:solr_document).and_return({ 'word_boundary_tsi' => nil }) }
      it "returns false" do
        expect(subject.ocr_file?).to eq false
      end
    end
    context "when OCR file is present" do
      context "with no text content" do
        before { allow(subject).to receive(:solr_document).and_return({ 'word_boundary_tsi' => '' }) }
        it "returns false" do
          expect(subject.ocr_file?).to eq false
        end
      end
      context "with text content" do
        before { allow(subject).to receive(:solr_document).and_return({ 'word_boundary_tsi' => 'text content' }) }
        it "returns true" do
          expect(subject.ocr_file?).to eq true
        end
      end
    end
  end
end
