module ESSI
  module PresentsNumPages
    delegate :num_pages, to: :solr_document
  end
end
