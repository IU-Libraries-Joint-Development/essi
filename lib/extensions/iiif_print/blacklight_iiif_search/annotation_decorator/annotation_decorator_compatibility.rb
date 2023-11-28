# customize behavior for IiifSearch
module Extensions
  module IiifPrint
    module BlacklightIiifSearch
      module AnnotationDecorator
        module AnnotationDecoratorCompatibility
          def self.included(base)
            base.class_eval do
              ##
              # This method is a workaround to compensate for index state where FileSets were indexed for the
              # blacklight_iiif_search gem; for those the object relation field is single value with a different name.
              # So not only do we have to know which one to check, we also can't call array methods on it.
              #
              # The purpose of this string is to figure out what to eliminate from the overall query to isolate
              # just the search terms.  So if this part doesn't match the query created in IiifSearchDecorator,
              # everything in the entire original query will then be incorrectly seen as terms and potentially even be
              # matched and highlighted.
              #
              # @return [String] Returns a string containing additional query terms based on the parent document's id.
              def additional_query_terms
                parent_id = document['is_page_of_ssim'].nil? ? document['is_page_of_ssi'] : document['is_page_of_ssim'].first
                " AND (is_page_of_ssim:\"#{parent_id}\" OR is_page_of_ssi:\"#{parent_id}\" OR id:\"#{parent_id}\")"
              end
            end
          end
        end
      end
    end
  end
end
