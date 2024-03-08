module Extensions
  module Hyrax
    module WorkShowPresenter
      module CollectionBanner
        def collection_banner_presenter
          @collection_banner_presenter ||= member_of_collection_presenters.first
        end
      end
    end
  end
end
