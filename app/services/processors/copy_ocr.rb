module Processors
  class CopyOCR < Hydra::Derivatives::Processors::Processor
    include Hydra::Derivatives::Processors::ShellBasedProcessor

    # def process
    #   output_file_service.call(File.open(@source_path, 'rb'), directives)
    # end
    #
    # def output_filename_for(_name)
    #   "#{File.basename(source_path, '.*')}.hocr"
    # end

    def self.encode(path, options, output_file)

    end
  end
end