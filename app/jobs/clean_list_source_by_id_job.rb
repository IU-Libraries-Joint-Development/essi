class CleanListSourceByIdJob < ApplicationJob
  queue_as 'important'

  # Cleans up extraneous list_source resources that were left behind when adding a file to an existing work when using OrderedMembersActor.
  def perform(id, batch_size = 100, perform_later = true)
    begin
      work = ActiveFedora::Base.find(id)
      perform_later ? CleanListSourceJob.perform_later(work, batch_size) : CleanListSourceJob.perform_now(work, batch_size)
    rescue => e
      Rails.logger.error(e.inspect)
      false
    end
  end
end
