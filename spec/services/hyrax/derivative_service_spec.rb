require 'rails_helper'

RSpec.describe Hyrax::DerivativeService do
  let(:image_work) { FactoryBot.create :image_with_one_image }
  let(:image_file) { File.join(fixture_path, 'world.png') }
  let(:file_set) { image_work.file_sets.first }
  let(:fsd_service) { described_class.for(file_set) }

  around(:each) do |example|
    original_chf_value = ESSI.config[:essi][:create_ocr_files]
    original_sd_value = ESSI.config[:essi][:skip_derivatives]
    example.call
    ESSI.config[:essi][:create_ocr_files] = original_chf_value
    ESSI.config[:essi][:skip_derivatives] = original_sd_value
  end

  before(:each) do
    allow(OCRRunner).to receive(:create).and_return(nil)
  end

  describe '.create_derivatives', :clean do
    context 'with a non-image' do
      before(:each) do
        allow(file_set).to receive(:mime_type).and_return('text/plain')
        ESSI.config[:essi][:create_ocr_files] = true
        ESSI.config[:essi][:skip_derivatives] = false
      end

      let(:file_set) { FactoryBot.create :file_set }

      it 'does not call OCRRunner' do
        expect(OCRRunner).not_to receive(:create)
        fsd_service.create_derivatives('test.txt')
      end
    end
    context 'with an image' do
      before(:each) do
        allow(file_set).to receive(:mime_type).and_return('image/png')
      end
      context 'with :create_ocr_files true' do
        before(:each) do
          ESSI.config[:essi][:create_ocr_files] = true
          ESSI.config[:essi][:skip_derivatives] = false
        end
        it 'calls OCRRunner' do
          expect(OCRRunner).to receive(:create)
          fsd_service.create_derivatives(image_file)
        end
      end
      context 'with :create_ocr_file false' do
        before(:each) do
          ESSI.config[:essi][:create_ocr_files] = false
          ESSI.config[:essi][:skip_derivatives] = false
        end
        it 'does not call OCRRunner' do
          expect(OCRRunner).not_to receive(:create)
          fsd_service.create_derivatives(image_file)
        end
      end
      context 'with :skip_derivatives true' do
        before(:each) do
          ESSI.config[:essi][:skip_derivatives] = true
          ESSI.config[:essi][:create_ocr_files] = true
        end
        it 'calls OCRunner' do
          expect(OCRRunner).to receive(:create)
          fsd_service.create_derivatives(image_file)
        end
        # simulate action of stubbed OCRRunner#create via Processor::OCR#encode_file
        it 'skips OCR generation in OCR Processor' do
          expect(Rails.logger).to receive(:info).with("Checking for a Pre-derived OCR folder.")
          expect(Processors::OCR).to receive(:skip_derivatives?).and_return(true)
          expect(Rails.logger).to receive(:info).with("No pre-derived file provided; skipping OCR generation")
          Processors::OCR.new(image_file,
                              { label: "test123-alto.xml",
                                mime_type: 'text/html; charset=utf-8',
                                format: 'xml',
                                container: 'extracted_text',
                                language: 'en',
                                url: 'www.example.com/test',
                                source_file_service: ::Hydra::Derivatives.source_file_service },
                              output_file_service: nil).process
        end
      end
      context 'with :skip_derivatives not set' do
        before(:each) do
          ESSI.config[:essi][:skip_derivatives] = nil
          ESSI.config[:essi][:create_ocr_files] = true
        end
        it 'does call OCRunner' do
          expect(OCRRunner).to receive(:create)
          fsd_service.create_derivatives(image_file)
        end
      end
    end
  end
end
