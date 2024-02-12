# modified from hyrax
module Extensions
  module AttachFilesToWorkWithOrderedMembersJob
    module ImportMetadata

      # modified to apply uploaded file metadata, if provided
      # @param [ActiveFedora::Base] work - the work object
      # @param [Array<Hyrax::UploadedFile>] uploaded_files - an array of files to attach
      def perform(work, uploaded_files, **work_attributes)
        # reintroduce file metadata somehow lost in direct actor --> job call
        (work_attributes.delete(:files_metadata) || []).each_with_index do |file_metadata, index|
          uploaded_files[index].metadata = file_metadata
        end
        super
      end

      private

        # modified to apply uploaded file metadata, if provided  
        def add_uploaded_files(user, metadata, work)
          work_permissions = work.permissions.map(&:to_hash)
          uploaded_files.each do |uploaded_file|
            file_set = FileSet.create({ label: label_for(uploaded_file), title: title_for(uploaded_file) })
            actor = file_set_actor_class.new(file_set, user)
            actor.create_metadata(metadata)
            actor.update_metadata(uploaded_file.metadata) if uploaded_file.metadata.present?
            actor.create_content(uploaded_file)
            actor.attach_to_work(work)
            actor.file_set.permissions_attributes = work_permissions
            ordered_members << actor.file_set
            uploaded_file.update(file_set_uri: actor.file_set.uri)
          end
        end

        def label_for(file)
          if file.is_a?(::Hyrax::UploadedFile) # filename not present for uncached remote file!
            file.uploader.filename.present? ? file.uploader.filename : File.basename(Addressable::URI.unencode(file.file_url))
          elsif file.respond_to?(:original_name) # e.g. Hydra::Derivatives::IoDecorator
            file.original_name
          end
        end

        def title_for(file)
          label_for(file) ? [label_for(file)] : []
        end
    end
  end
end
