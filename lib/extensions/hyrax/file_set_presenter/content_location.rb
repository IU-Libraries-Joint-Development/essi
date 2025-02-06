module Extensions
  module Hyrax
    module FileSetPresenter
      module ContentLocation
        delegate :content_location, to: :solr_document
      end
    end
  end
end
