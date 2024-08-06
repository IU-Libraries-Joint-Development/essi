module StructuralMetadata
  extend ActiveSupport::Concern

  included do
    has_subresource :logical_order, class_name: "LogicalOrderBase"
  end

  def to_solr(solr_doc = {})
    super.tap do |doc|
      doc[ActiveFedora.index_field_mapper.solr_name("logical_order",
                                                    :stored_searchable)] =
        [safe_logical_order_json]
      doc[ActiveFedora.index_field_mapper.solr_name("logical_order_headings",
                                                    :stored_searchable)] =
        logical_order.object.each_section.map(&:label)
    end
  end

  def safe_logical_order_json
    begin
      logical_order.order.to_json
    rescue => error
      Rails.logger.error "Error reading logical_order for #{self.class} #{self.id}: #{error.message}"
      {}.to_json
    end
  end
end
