# imported from hyrax
# A job to apply work permissions to all contained files set
#
class InheritPermissionsJob < Hyrax::ApplicationJob
  # Perform the copy from the work to the contained filesets
  #
  # @param work containing access level and filesets
  def perform(work, file_set: nil)
    if file_set
      perform_for_file(work, file_set)
    else
      work.file_sets.each do |file|
        perform_for_file(work, file)
      end
    end
  end

  private

    def perform_for_file(work,file)
      attribute_map = work.permissions.map(&:to_hash)

      # copy and removed access to the new access with the delete flag
      file.permissions.map(&:to_hash).each do |perm|
        unless attribute_map.include?(perm)
          perm[:_destroy] = true
          attribute_map << perm
        end
      end

      # apply the new and deleted attributes
      file.permissions_attributes = attribute_map
      file.save!
    end
end
