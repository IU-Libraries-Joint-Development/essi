# modified from hyrax: #save! call moved outside of loop
module Extensions
  module Hyrax
    module Actors
      module ApplyOrderActor
        module AddMembersSingleSave
          def add_new_work_ids_not_already_in_curation_concern(env, ordered_member_ids)
            (ordered_member_ids - env.curation_concern.ordered_member_ids).each do |work_id|
              work = ::ActiveFedora::Base.find(work_id)
              if can_edit_both_works?(env, work)
                env.curation_concern.ordered_members << work
              else
                env.curation_concern.errors[:ordered_member_ids] << "Works can only be related to each other if user has ability to edit both."
              end
            end
            env.curation_concern.save!
          end
        end
      end
    end
  end
end
