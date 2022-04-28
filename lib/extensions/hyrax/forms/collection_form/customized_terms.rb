module Extensions
  module Hyrax
    module Forms
      module CollectionForm
        module CustomizedTerms
          def self.included(base)
            base.class_eval do
              # modified from hyrax to include :campus, :source, :source_identifier
              self.terms = [:resource_type, :title, :creator, :contributor, :description,
                            :keyword, :license, :publisher, :date_created, :subject, :language,
                            :representative_id, :thumbnail_id, :identifier, :based_near,
                            :campus, :related_url, :visibility, :collection_type_gid, :source, :source_identifier]
        
              self.required_fields = [:title]
        
              # Terms that appear above the accordion
              # Modified from hyrax to include :source, :source_identifier
              def primary_terms
                [:title, :description, :source, :source_identifier]
              end
        
              # Terms that appear within the accordion
              # Modified from hyrax to include :campus
              def secondary_terms
                [:creator,
                 :contributor,
                 :keyword,
                 :license,
                 :publisher,
                 :date_created,
                 :subject,
                 :language,
                 :identifier,
                 :based_near,
                 :campus,
                 :related_url,
                 :resource_type]
              end
            end
          end
        end
      end
    end
  end
end
