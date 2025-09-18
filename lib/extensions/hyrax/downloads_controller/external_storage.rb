# Handle files from external storage
module Extensions
  module Hyrax
    module DownloadsController
      module ExternalStorage
        def show
          if params[:file] && params[:file] == 'extracted_text'
            super
          elsif asset.try(:external?)
            ext_id = asset.external_id
            external_asset = ESSI.external_storage.get(ext_id)
            send_data external_asset.body.read, filename: ext_id
          else
            super
          end
        end
      end
    end
  end
end
