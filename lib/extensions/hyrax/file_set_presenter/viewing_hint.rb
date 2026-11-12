module Extensions
  module Hyrax
    module FileSetPresenter
      module ViewingHint
        delegate :viewing_hint, :thumbnail_id, :thumbnail_path, to: :solr_document
      end
    end
  end
end  
