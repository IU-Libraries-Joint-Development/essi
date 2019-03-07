require 'rails_helper'

RSpec.describe Hyrax::FileSetDerivativesService do
  let(:image_file) { File.join(fixture_path, 'world.png') }
  let(:file_set) { FactoryBot.create :file_set }
  let(:fsd_service) { described_class.new(file_set) }

  around(:each) do |example|
    original_value = ESSI.config[:essi][:create_hocr_files]
    example.call
    ESSI.config[:essi][:create_hocr_files] = original_value
  end

  before(:each) do
    allow(OCRRunner).to receive(:create).and_return(nil)
  end

  describe '.create_derivatives' do
    context 'with a non-image' do
      before(:each) do
        allow(file_set).to receive(:mime_type).and_return('text/plain')
        ESSI.config[:essi][:create_hocr_files] = true
      end
      it 'does not call OCRRunner' do
        expect(OCRRunner).not_to receive(:create)
        fsd_service.create_derivatives('test.txt')
      end
    end
    context 'with an image' do
      before(:each) do
        allow(file_set).to receive(:mime_type).and_return('image/png')
      end
      context 'with :create_hocr_files true' do
        before(:each) do
          ESSI.config[:essi][:create_hocr_files] = true
        end
        it 'calls OCRRunner' do
          expect(OCRRunner).to receive(:create)
          fsd_service.create_derivatives(image_file)
        end
      end
      context 'with :create_hocr_file false' do
        before(:each) do
          ESSI.config[:essi][:create_hocr_files] = false
        end
        it 'does not call OCRRunner' do
          expect(OCRRunner).not_to receive(:create)
          fsd_service.create_derivatives(image_file)
        end
      end
    end
  end
end
