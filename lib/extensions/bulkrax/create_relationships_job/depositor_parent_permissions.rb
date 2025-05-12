# modified from bulkrax 5.5.1
module Extensions
  module Bulkrax
    module CreateRelationshipsJob
      module DepositorParentPermissions
        # modified to accept :deposit or :edit permissions on parent
        def process(relationship:, importer_run_id:, parent_record:, ability:)
          raise "#{relationship} needs a child to create relationship" if relationship.child_id.nil?
          raise "#{relationship} needs a parent to create relationship" if relationship.parent_id.nil?
    
          _child_entry, child_record = find_record(relationship.child_id, importer_run_id)
          raise "#{relationship} could not find child record" unless child_record
    
          raise "Cannot add child collection (ID=#{relationship.child_id}) to parent work (ID=#{relationship.parent_id})" if child_record.collection? && parent_record.work?
    
          ability.authorize!(:edit, child_record)
    
          # We could do this outside of the loop, but that could lead to odd counter failures.
          # modified to accept :deposit or :edit permissions on parent
          ability.authorize!(:edit, parent_record) unless ability.can?(:deposit, parent_record)
    
          parent_record.is_a?(::Collection) ? add_to_collection(child_record, parent_record) : add_to_work(child_record, parent_record)
    
          child_record.file_sets.each(&:update_index) if update_child_records_works_file_sets? && child_record.respond_to?(:file_sets)
          relationship.destroy
        end
      end
    end
  end
end
