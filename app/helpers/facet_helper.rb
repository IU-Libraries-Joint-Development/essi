module FacetHelper
  def campus_label(value)
    CampusService.find(value)[:term] || ''
  end

  # imported from hyrax to prep campus-specific version
  # @param item [Object]
  # @param field [String]
  # @return [ActiveSupport::SafeBuffer] the html_safe link
  def link_to_facet(item, field)
    path = main_app.search_catalog_path(search_state.add_facet_params_and_redirect(field, item))
    link_to(item, path)
  end
end
