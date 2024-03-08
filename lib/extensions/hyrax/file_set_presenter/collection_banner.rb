module Extensions
  module Hyrax
    module FileSetPresenter
      module CollectionBanner
        def collection
          @collection ||= parent&.collection
        end
      end
    end
  end
end
