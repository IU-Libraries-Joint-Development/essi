# frozen_string_literal: true

module Bulkrax
  class MetsXmlParser < XmlParser
    # unmodified from XmlParser
    def entry_class
      Bulkrax::XmlEntry
    end

    # unmodified from ApplicationParser
    def create_relationships; end
  end
end
