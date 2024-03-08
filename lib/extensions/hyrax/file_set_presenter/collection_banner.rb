module Extensions
  module Hyrax
    module FileSetPresenter
      module CollectionBanner
        def collection_banner_presenter
          @collection_banner_presenter ||= parent&.collection_banner_presenter
        end
      end
    end
  end
end
