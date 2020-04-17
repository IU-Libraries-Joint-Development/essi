module ESSI
  module Actors
    class PerformLaterActor < Hyrax::Actors::AbstractActor
      def create(env)
        # Short circuit to next actor if we are running from a job.
        if env.attributes.delete 'in_perform_later_actor_job'
          super
        else
          env.attributes['in_perform_later_actor_job'] = true
          PerformLaterActorJob.perform_later('create', env.curation_concern.class.to_s, env.current_ability.current_user, env.attributes)
        end
      end
    end
  end
end
