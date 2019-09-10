Blacklight::UrlHelperBehavior.module_eval do
  # link_to_document(doc, 'VIEW', :counter => 3)
  # Use the catalog_path RESTful route to create a link to the show page for a specific item.
  # catalog_path accepts a hash. The solr query params are stored in the session,
  # so we only need the +counter+ param here. We also need to know if we are viewing to document as part of search results.
  # TODO: move this to the IndexPresenter
  def link_to_document(doc, field_or_opts = nil, opts = { counter: nil })
    if field_or_opts.is_a? Hash
      opts = field_or_opts
    else
      field = field_or_opts
    end

    field ||= document_show_link_field(doc)
    label = index_presenter(doc).label field, opts
    # Pass search on to item view.
    url = add_highlight_url(doc)
    link_to label, url, document_link_params(doc, opts)
  end

  # Adds search term to be highlighed on item
  # to catalog search URL
  #
  # @param [Object] SOLR document
  # @return [String] url string
  def add_highlight_url(doc)
    params['q'].present? ? [doc, query: CGI.escape(params['q'])] : url_for_document(doc)
  end
end
