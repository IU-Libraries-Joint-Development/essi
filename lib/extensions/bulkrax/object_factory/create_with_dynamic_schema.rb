module Extensions
  module Bulkrax
    module ObjectFactory
      module CreateWithDynamicSchema
        # unmodified from bulkrax 5.x
        def create
          attrs = transform_attributes
          @object = klass.new
          object.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX if defined?(Hyrax::Adapters::NestingIndexAdapter) && object.respond_to?(:reindex_extent)
          run_callbacks :save do
            run_callbacks :create do
              if klass == Collection
                create_collection(attrs)
              elsif klass == FileSet
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
