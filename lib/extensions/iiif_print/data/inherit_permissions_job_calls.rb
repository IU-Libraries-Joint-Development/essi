# modified from iiif_print
# removes FileSet job calls handled elsewhere
module Extensions
  module IiifPrint
    module Data
      module InheritPermissionsJobCalls
        def self.included(base)
          base.class_eval do
            # Handler for after_create_fileset, to be called by block subscribing to
            #   and overriding default Hyrax `:after_create_fileset` handler, via
            #   app integrating iiif_print.
            def self.handle_after_create_fileset(file_set, user)
              handle_queued_derivative_attachments(file_set)
              # Hyrax queues this job by default, and since iiif_print
              #   overrides the single subscriber Hyrax uses to do so, we
              #   must call this here:
              ::FileSetAttachedEventJob.perform_later(file_set, user)
            end
          end
        end
      end
    end
  end
end
