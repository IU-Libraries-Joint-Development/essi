# unmodified from iiif_print to
module Extensions
  module IiifPrint
    module Metadata
      module FacetedValuesForCampus
        def faceted_values_for(field_name:)
          values_for(field_name: field_name).map do |value|
            search_field = field_name.to_s + "_sim"
            path = Rails.application.routes.url_helpers.search_catalog_path(
              "f[#{search_field}][]": value, locale: I18n.locale
            ) 
            path += '&include_child_works=true' if work["is_child_bsi"] == true
            "<a href='#{File.join(@base_url, path)}'>#{value}</a>"
          end
        end 
      end
    end
  end
end
