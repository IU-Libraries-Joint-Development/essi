# modified from iiif_print
# uses version of find_or_retrieve that is aware of external storage
module Extensions
  module IiifPrint
    module Data
      module WorkFile
        module ExternalFileLocation
          private
    
          def checkout
            @fileset.find_or_retrieve
          end
        end
      end
    end
  end
end
