# unmodified from iiif_manifest
module Extensions
  module IIIFManifest
    module ManifestBuilder
      module DeepFileSetEnumerator
        module NestedEach
          # lists all direct file_set members, then recurs through work members
          def each(&block)
            file_set_presenters.each do |file_set_presenter|
              yield file_set_presenter
            end
            work_presenters.each do |work_presenter|
              self.class.new(work_presenter).each(&block)
            end
          end

          private
            def file_set_presenters
              @file_set_presenters ||= work.try(:file_set_presenters) || []
            end

            def work_presenters
              @work_presenters ||= work.try(:work_presenters) || []
            end
        end
      end
    end
  end
end
