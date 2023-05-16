module Processors
  class OCR < Hydra::Derivatives::Processors::Processor
    include Hydra::Derivatives::Processors::ShellBasedProcessor
    extend PrederivationHelper

    def self.encode(path, options, output_file)
      file_name = File.basename(path)
      existing_file = pre_ocr_file(file_name)
      if existing_file
        Rails.logger.info "Copying Pre-derived OCR file #{existing_file} to #{output_file}."
        execute "cp #{existing_file} #{output_file}"
      elsif skip_derivatives?
        Rails.logger.info "No pre-derived file provided; skipping OCR generation"
      elsif preprocess_ocr?
        Rails.logger.info "Pre-processing #{path} before OCR derivation."
        bitonal_file = ocr_clean_file(path)
        execute "OMP_THREAD_LIMIT=1 tesseract #{bitonal_file} #{output_file.gsub('.xml', '')} #{options[:options]} alto"
        remove_tmp_file(bitonal_file)
      else
        Rails.logger.info "Deriving OCR directly from #{path}."
        execute "OMP_THREAD_LIMIT=1 tesseract #{path} #{output_file.gsub('.xml', '')} #{options[:options]} alto"
      end
    end

    def options_for(_format)
      {
        options: string_options
      }
    end

    def self.pre_ocr_file(filename)
      self.pre_derived_file(filename, type: 'OCR')
    end

    def self.preprocess_ocr?
      ocr_preprocessor.present? && File.exists?(ocr_preprocessor)
    end

    def self.ocr_preprocessor
      @ocr_preprocessor ||= ESSI.config.dig(:essi, :ocr_preprocessor_path)
    end

    def self.ocr_clean_file(path)
      clean_file = File.join(Hydra::Derivatives.temp_file_base, "clean_#{File.basename(path)}")
      execute "#{ocr_preprocessor} #{path} #{clean_file}"
      clean_file
    end

    def self.remove_tmp_file(file)
      execute "rm #{file}"
    end

    def self.skip_derivatives?
      ESSI.config.dig(:essi, :skip_derivatives)
    end

    private

    def string_options
      "-l #{language}"
    end

    def language
      directives.fetch(:language, :eng)
    end
  end
end
