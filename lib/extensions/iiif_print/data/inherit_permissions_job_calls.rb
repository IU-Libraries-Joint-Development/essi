# modified from iiif_print
# makes FileSet-specific call to InheritPermissionsJob
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
              work = file_set.member_of[0]
              # Hyrax CreateWithRemoteFilesActor has glaring omission re: this job,
              #   so we call it here, once we have a fileset to copy permissions to.
              ::InheritPermissionsJob.perform_later(work, file_set: file_set) unless work.nil?
            end
          end
        end
      end
    end
  end
end
