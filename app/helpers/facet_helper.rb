module FacetHelper
  def campus_label(value)
    CampusService.find(value)[:term] || ''
  end

  # campus-specific version of link_to_facet
  # @param item [Object]
  # @param field [String]
  # @return [ActiveSupport::SafeBuffer] the html_safe link
  def link_to_campus_facet(item, field)
    path = main_app.search_catalog_path(search_state.add_facet_params_and_redirect(field, item))
    item = campus_label(item)
    link_to(item, path)
  end
end
