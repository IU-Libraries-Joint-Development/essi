module Extensions
  module Bulkrax
    module ObjectFactory
      module CreateWithDynamicSchema
        # modified from bulkrax 5.x to apply a supplied dynamic_schema_id to initial object build
        def create
          attrs = transform_attributes
          init_attrs = {}
          init_attrs = { dynamic_schema_id: attrs[:dynamic_schema_id] } if attrs[:dynamic_schema_id].present? && klass.new.respond_to?(:dynamic_schema_id)
          @object = klass.new(init_attrs)
          object.reindex_extent = ::Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX if defined?(::Hyrax::Adapters::NestingIndexAdapter) && object.respond_to?(:reindex_extent=)
          run_callbacks :save do
            run_callbacks :create do
              if klass == ::Collection
                create_collection(attrs)
              elsif klass == ::FileSet
                create_file_set(attrs)
              else
                create_work(attrs)
              end
            end
          end
          object.apply_depositor_metadata(@user) && object.save! if object.depositor.nil?
          log_created(object)
        end
      end
    end
  end
end
