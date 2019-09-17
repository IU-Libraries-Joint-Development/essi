module Processors
  class CopyOCR < Hydra::Derivatives::Processors::Processor
    include Hydra::Derivatives::Processors::ShellBasedProcessor

    def self.encode(path, _options, output_file)
      execute "cp #{path} #{output_file}"
    end

  end
end