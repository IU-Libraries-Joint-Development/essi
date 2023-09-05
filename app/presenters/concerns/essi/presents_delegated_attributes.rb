module ESSI
  module PresentsDelegatedAttributes
    delegate :num_pages, :number_of_pages, :catalog_url, :related_url, :version, to: :solr_document
  end
end
