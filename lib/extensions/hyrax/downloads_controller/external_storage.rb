# Handle files from external storage
module Extensions
  module Hyrax
    module DownloadsController
      module ExternalStorage
        def show
          if params[:file] && params[:file] == 'extracted_text'
            super
          elsif asset.content_location&.start_with?('s3://')
            ext_id = asset.content_location.split('/').last
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
