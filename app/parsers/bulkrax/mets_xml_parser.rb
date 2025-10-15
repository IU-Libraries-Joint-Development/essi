# frozen_string_literal: true

module Bulkrax
  class MetsXmlParser < XmlParser
    # modified from XmlParser
    def entry_class
      Bulkrax::MetsXmlEntry
    end

    # modified from ApplicationParser
    def create_relationships
      if parser_fields['collection_id'].present?
        ScheduleRelationshipsJob.set(wait: 5.minutes).perform_later(importer_id: importerexporter.id)
      end
    end
  end
end
