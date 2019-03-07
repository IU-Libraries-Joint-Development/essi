class PersistDirectlyContainedOutputFileService < Hyrax::PersistDirectlyContainedOutputFileService
    def self.call(content, directives)
      file = io(content, directives)
      file_set = retrieve_file_set(directives)
      remote_file = retrieve_remote_file(file_set, directives)
      remote_file.content = file
      remote_file.mime_type = directives.fetch(:mime_type, determine_mime_type(file))
      remote_file.original_name = directives.fetch(:label, determine_original_name(file))
      remote_file.save
      file_set.save
    end

    # guard against super returning a blank result
    # @param file [Hydra::Derivatives::IoDecorator]
    def self.determine_original_name(file)
      result = super
      result.present? ? result : "derivative"
    end

    # guard against super returning a blank result
    # @param file [Hydra::Derivatives::IoDecorator]
    def self.determine_mime_type(file)
      result = super
      result.present? ? result : "application/octet-stream"
    end
end
