# frozen_string_literal: true

module Hyrax
  module Actors
    class OrderedMembersActor < FileSetActor
      include Lockable
      attr_reader :ordered_members, :user

      def initialize(ordered_members, user)
        @ordered_members = ordered_members
        @user = user
      end

      # Adds FileSets to the work using ore:Aggregations.
      # Locks to ensure that only one process is operating on the list at a time.
      # @param [ActiveFedora::Base] work the parent work
      def attach_ordered_members_to_work(work)
        acquire_lock_for(work.id) do
          # Modified to avoid recreating hasPart entries in the list_source with new identifiers.
          # The old resources were not cleaned up, leading to poor list_source performance.
          new_members = ordered_members - work.ordered_members
          work.ordered_members.concat(new_members)
          work.save
          ordered_members.each do |file_set|
            Hyrax.config.callback.run(:after_create_fileset, file_set, user)
          end
        end
      end
    end
  end
end
