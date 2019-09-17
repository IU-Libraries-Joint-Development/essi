module Processors
  class OCR < Hydra::Derivatives::Processors::Processor
    include Hydra::Derivatives::Processors::ShellBasedProcessor

    def self.encode(path, options, output_file)
      existing_file = pre_hocr_file(path)

      execute "tesseract #{path} #{output_file.gsub('.hocr', '')}" \
      " #{options[:options]} hocr" unless existing_file

      Rails.logger.info "Copying File #{existing_file} to #{output_file}"
      execute "cp #{existing_file} #{output_file}"
    end

    def options_for(_format)
      {
        options: string_options
      }
    end

    def self.pre_hocr_file(filename)
      Rails.logger.info 'Checking for a Pre-derived OCR folder.'
      return false unless ESSI.config.dig(:essi, :derivatives_folder)

      Rails.logger.info 'Checking for a Pre-derived OCR File.'
      ocr_filename = "#{File.basename(filename, '.*')}.hocr"
      ocr_file = File.join(ESSI.config.dig(:essi, :derivatives_folder), ocr_filename)
      return false unless File.exist?(ocr_file)

      ocr_file
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
