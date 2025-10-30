# unmodified from iiif_print
module Extensions
  module IiifPrint
    module Data
      module WorkFile
        module ExternalFileLocation
          private
    
          def checkout
            file = @fileset.original_file
            # find_or_retrieve returns path to working copy, but only
            #   fetches from Fedora if no working copy exists on filesystem.
            # NOTE: there may be some benefit to memoizing to avoid
            #   call and File.exist? IO operation, but YAGNI for now.
            Hyrax::WorkingDirectory.find_or_retrieve(file.id, @fileset.id)
          end
        end
      end
    end
  end
end
