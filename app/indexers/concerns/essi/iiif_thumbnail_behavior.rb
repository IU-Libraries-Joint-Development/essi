module ESSI
  module IIIFThumbnailBehavior
    extend ActiveSupport::Concern

    included do
      self.thumbnail_path_service = IIIFThumbnailPathService
    end
  end
end
