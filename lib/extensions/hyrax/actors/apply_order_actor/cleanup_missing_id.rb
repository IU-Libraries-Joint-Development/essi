# modified from hyrax: skip any nil ids
module Extensions
  module Hyrax
    module Actors
      module ApplyOrderActor
        module CleanupMissingId
          def cleanup_ids_to_remove_from_curation_concern(curation_concern, ordered_member_ids)
            (curation_concern.ordered_member_ids - ordered_member_ids).each do |old_id|
              next unless old_id
              work = ::ActiveFedora::Base.find(old_id)
              curation_concern.ordered_members.delete(work)
              curation_concern.members.delete(work)
            end
          end
        end
      end
    end
  end
end
