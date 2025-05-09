class CatalogController < ApplicationController
  include Hydra::Catalog
  include Hydra::Controller::ControllerBehavior
  include ESSI::DynamicCatalogBehavior
  # This filter applies the hydra access controls
  before_action :enforce_show_permissions, only: :show

  def self.uploaded_field
    solr_name('system_create', :stored_sortable, type: :date)
  end

  def self.modified_field
    solr_name('system_modified', :stored_sortable, type: :date)
  end


  # CatalogController-scope behavior and configuration for BlacklightIiifSearch
  include BlacklightIiifSearch::Controller

  configure_blacklight do |config|
    # IiifPrint index fields
    config.add_index_field 'all_text_tsimv', highlight: true, helper_method: :render_ocr_snippets

    # configuration for Blacklight IIIF Content Search
    config.iiif_search = {
      iiif_index_strategy: 'iiif_print_v1.0',
      full_text_field: 'all_text_tsimv',
      object_relation_field: 'is_page_of_ssim',
      extra_relation_field: 'is_page_of_ssi',
      supported_params: %w[q page],
      autocomplete_handler: 'iiif_suggest',
      suggester_name: 'iiifSuggester'
    }

    config.view.gallery.partials = [:index_header, :index]
    config.view.masonry.partials = [:index]
    # config.view.slideshow.partials = [:index]


    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    config.search_builder_class = IiifPrint::CatalogSearchBuilder

    # Show gallery view
    config.view.gallery.partials = [:index_header, :index]
    # config.view.slideshow.partials = [:index]

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: "search",
      rows: 10,
      qf: "title_tesim description_tesim abstract_tesim creator_tesim keyword_tesim ocr_text_tesi word_boundary_tsi all_text_timv",
    }

    # solr field configuration for document/show views
    config.index.title_field = solr_name("title", :stored_searchable)
    config.index.display_type_field = solr_name("has_model", :symbol)
    config.index.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    config.add_facet_field solr_name("human_readable_type", :facetable), label: "Type", limit: true
    config.add_facet_field solr_name("resource_type", :facetable), label: "Resource Type", limit: true
    config.add_facet_field solr_name("creator", :facetable), limit: true
    config.add_facet_field solr_name("contributor", :facetable), label: "Contributor", limit: true
    config.add_facet_field solr_name("keyword", :facetable), limit: true
    config.add_facet_field solr_name("subject", :facetable), limit: true
    config.add_facet_field solr_name("language", :facetable), limit: true
    config.add_facet_field solr_name("based_near_label", :facetable), limit: true
    config.add_facet_field solr_name("publisher", :facetable), limit: true
    config.add_facet_field solr_name("file_format", :facetable), limit: true
    config.add_facet_field solr_name('date_created', :facetable),
      label: 'Date Created', limit: true
    config.add_facet_field solr_name('num_pages', :facetable, type: :integer),
      sort: 'index', label: 'Pages', limit: true
    config.add_facet_field solr_name('member_of_collection_ids', :symbol),
      limit: true, label: 'Collections', helper_method: :collection_title_by_id
    config.add_facet_field 'workflow_state_name_ssim', label: 'State'
    config.add_facet_field solr_name("campus", :facetable), label: 'Campus', limit: true, helper_method: :campus_label

    # The generic_type isn't displayed on the facet list
    # It's used to give a label to the filter that comes from the user profile
    config.add_facet_field solr_name("generic_type", :facetable), if: false

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field solr_name("title", :stored_searchable), label: "Title", itemprop: 'name', if: false
    config.add_index_field solr_name("description", :stored_searchable), itemprop: 'description', helper_method: :iconify_auto_link
    config.add_index_field solr_name("keyword", :stored_searchable), itemprop: 'keywords', link_to_search: solr_name("keyword", :facetable)
    config.add_index_field solr_name("subject", :stored_searchable), itemprop: 'about', link_to_search: solr_name("subject", :facetable)
    config.add_index_field solr_name("series", :stored_searchable), label: 'Series', link_to_search: solr_name("series", :facetable)
    config.add_index_field solr_name("creator", :stored_searchable), itemprop: 'creator', link_to_search: solr_name("creator", :facetable)
    config.add_index_field solr_name("contributor", :stored_searchable), itemprop: 'contributor', link_to_search: solr_name("contributor", :facetable)
    config.add_index_field solr_name("proxy_depositor", :symbol), label: "Depositor", helper_method: :link_to_profile
    config.add_index_field solr_name("depositor"), label: "Owner", helper_method: :link_to_profile, if: lambda { |context, _field_config, _document| context.try(:current_user)&.admin? }
    config.add_index_field solr_name("publisher", :stored_searchable), itemprop: 'publisher', link_to_search: solr_name("publisher", :facetable)
    config.add_index_field solr_name("based_near_label", :stored_searchable), itemprop: 'contentLocation', link_to_search: solr_name("based_near_label", :facetable)
    config.add_index_field solr_name("language", :stored_searchable), itemprop: 'inLanguage', link_to_search: solr_name("language", :facetable)
    config.add_index_field solr_name("date_uploaded", :stored_sortable, type: :date), itemprop: 'datePublished', helper_method: :human_readable_date, if: lambda { |context, _field_config, _document| context.try(:current_user)&.admin? }
    config.add_index_field solr_name("date_modified", :stored_sortable, type: :date), itemprop: 'dateModified', helper_method: :human_readable_date, if: lambda { |context, _field_config, _document| context.try(:current_user)&.admin? }
    config.add_index_field solr_name("date_created", :stored_searchable), itemprop: 'dateCreated'
    config.add_index_field solr_name("rights_statement", :stored_searchable), helper_method: :rights_statement_links
    config.add_index_field solr_name("license", :stored_searchable), helper_method: :license_links
    config.add_index_field solr_name("resource_type", :stored_searchable), label: "Resource Type", link_to_search: solr_name("resource_type", :facetable)
    config.add_index_field solr_name("file_format", :stored_searchable), link_to_search: solr_name("file_format", :facetable)
    config.add_index_field solr_name("identifier", :stored_searchable), helper_method: :index_field_link, field_name: 'identifier'
    config.add_index_field solr_name("embargo_release_date", :stored_sortable, type: :date), label: "Embargo release date", helper_method: :human_readable_date
    config.add_index_field solr_name("lease_expiration_date", :stored_sortable, type: :date), label: "Lease expiration date", helper_method: :human_readable_date
    config.add_index_field solr_name('num_pages', :facetable, type: :integer), label: 'Pages'
    config.add_index_field 'workflow_state_name_ssim', label: 'State', if: lambda { |context, _field_config, _document| context.try(:current_user)&.admin? }

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field solr_name("title", :stored_searchable)
    config.add_show_field solr_name("description", :stored_searchable)
    config.add_show_field solr_name("keyword", :stored_searchable)
    config.add_show_field solr_name("subject", :stored_searchable)
    config.add_show_field solr_name("creator", :stored_searchable)
    config.add_show_field solr_name("contributor", :stored_searchable)
    config.add_show_field solr_name("publisher", :stored_searchable)
    config.add_show_field solr_name("based_near_label", :stored_searchable)
    config.add_show_field solr_name("language", :stored_searchable)
    config.add_show_field solr_name("date_uploaded", :stored_searchable), if: lambda { |context, _field_config, _document| context.try(:current_user)&.admin? }
    config.add_show_field solr_name("date_modified", :stored_searchable), if: lambda { |context, _field_config, _document| context.try(:current_user)&.admin? }
    config.add_show_field solr_name("date_created", :stored_searchable)
    config.add_show_field solr_name("rights_statement", :stored_searchable)
    config.add_show_field solr_name("license", :stored_searchable)
    config.add_show_field solr_name("resource_type", :stored_searchable), label: "Resource Type"
    config.add_show_field solr_name("format", :stored_searchable)
    config.add_show_field solr_name("identifier", :stored_searchable)
    config.add_show_field solr_name('num_pages', :facetable, type: :integer)
    config.add_show_field 'workflow_state_name_ssim', label: 'State', if: lambda { |context, _field_config, _document| context.try(:current_user)&.admin? }

    # manually add if conditional for some fields
    config.add_index_field solr_name('ocr_state', :stored_searchable), label: 'OCR State', if: lambda { |context, _field_config, _document| context.try(:current_user)&.admin? }
    config.add_index_field solr_name('viewing_direction', :stored_searchable), label: 'Viewing direction', if: lambda { |context, _field_config, _document| context.try(:current_user)&.admin? }
    config.add_index_field solr_name('source_identifier', :stored_searchable), label: 'Source identifier', if: lambda { |context, _field_config, _document| context.try(:current_user)&.admin? }
    config.add_index_field solr_name('source_metadata_identifier', :stored_searchable), label: 'Source metadata identifier', if: lambda { |context, _field_config, _document| context.try(:current_user)&.admin? }
    config.add_index_field solr_name('viewing_hint', :stored_searchable), label: 'Viewing hint', if: lambda { |context, _field_config, _document| context.try(:current_user)&.admin? }

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.
    #
    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field('all_fields', label: 'All Fields') do |field|
      all_names = config.show_fields.values.map(&:field).join(" ")
      title_name = solr_name("title", :stored_searchable)
      field.solr_parameters = {
        qf: "#{all_names} file_format_tesim all_text_timv",
        pf: title_name.to_s
      }
    end

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.
    # creator, title, description, publisher, date_created,
    # subject, language, resource_type, format, identifier, based_near,
    config.add_search_field('contributor') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      solr_name = solr_name("contributor", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('creator') do |field|
      solr_name = solr_name("creator", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('title') do |field|
      solr_name = solr_name("title", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('description') do |field|
      field.label = "Abstract or Summary"
      solr_name = solr_name("description", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('publisher') do |field|
      solr_name = solr_name("publisher", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('date_created') do |field|
      solr_name = solr_name("created", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('subject') do |field|
      solr_name = solr_name("subject", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('language') do |field|
      solr_name = solr_name("language", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('resource_type') do |field|
      solr_name = solr_name("resource_type", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('format') do |field|
      solr_name = solr_name("format", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('identifier') do |field|
      solr_name = solr_name("id", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('based_near') do |field|
      field.label = "Location"
      solr_name = solr_name("based_near_label", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('keyword') do |field|
      solr_name = solr_name("keyword", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('depositor') do |field|
      solr_name = solr_name("depositor", :symbol)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('rights_statement') do |field|
      solr_name = solr_name("rights_statement", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('license') do |field|
      solr_name = solr_name("license", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # label is key, solr field is value
    config.add_sort_field "score desc, #{uploaded_field} desc",
      label: "relevance \u25BC"
    config.add_sort_field "#{modified_field} desc", label: "recently updated"
    config.add_sort_field \
      "#{solr_name('sort_title', :stored_sortable, type: :string)} asc",
      label: "title \u25B2"
    config.add_sort_field \
      "#{solr_name('sort_title', :stored_sortable, type: :string)} desc",
      label: "title \u25BC"
    config.add_sort_field \
      "#{solr_name('date_created', :stored_sortable, type: :integer)} asc",
      label: "date created \u25B2"
    config.add_sort_field \
      "#{solr_name('date_created', :stored_sortable, type: :integer)} desc",
      label: "date created \u25BC"
    config.add_sort_field \
      "#{solr_name('number_of_pages', :stored_sortable, type: :integer)} asc",
      label: "pages \u25B2"
    config.add_sort_field \
      "#{solr_name('number_of_pages', :stored_sortable, type: :integer)} desc",
      label: "pages \u25BC"
    config.add_sort_field \
      "#{solr_name('num_works', :stored_sortable, type: :integer)} asc",
      label: "collection size \u25B2"
    config.add_sort_field \
      "#{solr_name('num_works', :stored_sortable, type: :integer)} desc",
      label: "collection size \u25BC"

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
  end

  # disable the bookmark control from displaying in gallery view
  # Hyrax doesn't show any of the default controls on the list view, so
  # this method is not called in that context.
  def render_bookmarks_control?
    false
  end
end
