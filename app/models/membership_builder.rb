class MembershipBuilder
  include ExtraLockable
  attr_reader :work, :members

  def initialize(work, members)
    @work = work
    @members = members
  end

  def attach_files_to_work
    return if @members.empty?
    acquire_lock_for(work.id) do
      # Ensure we have an up-to-date copy of the members association, so
      # that we append to the end of the list.
      work.reload unless work.new_record?
      members.each do |member|
        work.ordered_members << member
      end
      work.representative = members.first if work.representative_id.blank?
      work.thumbnail = members.first if work.thumbnail_id.blank?
      work.save
    end
  end
end

