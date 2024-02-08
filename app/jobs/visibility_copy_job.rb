# imported from hyrax
# modified to optionally specify single FileSet
# modified to handle nil value for work
# modified to log empty file_sets membership
# modified to short circuit unneeded saves
#
# Responsible for copying the following attributes from the work to each file in the file_sets
#
# * visibility
# * lease
# * embargo
class VisibilityCopyJob < Hyrax::ApplicationJob
  # @api public
  # @param [#file_sets, #visibility, #lease, #embargo] work - a Work model
  def perform(work, file_set: nil)
    if work.nil?
      Rails.logger.debug "#{self.class} called with nil work, file_set #{file_set&.id || 'nil' }. Skipping perform."
    elsif file_set
      perform_for_file(work, file_set)
    elsif work.file_sets.none?
      Rails.logger.debug "#{self.class} called with no file_sets for work #{work.id}. Skipping perform."
    else
      work.file_sets.each do |file|
        perform_for_file(work, file)
      end
    end
  end

  private

    def perform_for_file(work, file)
      file.visibility = work.visibility # visibility must come first, because it can clear an embargo/lease
      copy_visibility_modifier(work: work, file: file, modifier: :lease)
      copy_visibility_modifier(work: work, file: file, modifier: :embargo)
      file.save! if file.visibility_changed?
    end

    def copy_visibility_modifier(work:, file:, modifier:)
      work_modifier = work.public_send(modifier)
      return unless work_modifier
      file_modifier = file.public_send(modifier) || file.public_send("build_#{modifier}")
      file_modifier.attributes = work_modifier.attributes.except('id')
      file_modifier.save if file_modifier.changed?
    end
end
