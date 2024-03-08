require 'rails_helper'

RSpec.describe Hyrax::WorkShowPresenter do
  subject { described_class.new(double, double) }

  before do
    name = ['The Collection', 'Another Collection']
    @snake = 'the_collection'
    @title = 'The Title'
    @url = 'http://university.edu'
    allow(subject).to receive(:admin_set).and_return(name)
    @campus_logos = ESSI.config[:essi][:campus_logos]
  end

  context 'When initialized' do
    it '.collection_banner_presenter is available' do
      expect(subject).to respond_to(:collection_banner_presenter)
    end
    it '.campus_logo is available' do
      expect(subject).to respond_to(:campus_logo)
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
end
