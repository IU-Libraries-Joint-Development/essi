module ESSI
  class FileSetIndexer < Hyrax::FileSetIndexer
    include ESSI::IIIFThumbnailBehavior
  end
end
