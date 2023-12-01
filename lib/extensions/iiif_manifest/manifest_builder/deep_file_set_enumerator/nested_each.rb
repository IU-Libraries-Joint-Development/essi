# modified from iiif_manifest
module Extensions
  module IIIFManifest
    module ManifestBuilder
      module DeepFileSetEnumerator
        module NestedEach
          # modified from iiif_manifest
          # lists all direct file_set members and member works' file_sets, interspersed
          def each(&block)
            member_presenters.each do |member_presenter|
              if member_presenter.id.in? file_set_presenters.map(&:id)
                yield file_set_presenters.find { |fp| fp.id == member_presenter.id }
              elsif member_presenter.id.in? work_presenters.map(&:id)
                self.class.new(work_presenters.find { |wp| wp.id == member_presenter.id } ).each(&block)
              end
            end
          end

          private
            # modified from iiif_manifest with memoization
            def file_set_presenters
              @file_set_presenters ||= work.try(:file_set_presenters) || []
            end

            def member_presenters
              @member_presenters ||= work.try(:member_presenters) || []
            end

            # modified from iiif_manifest with memoization
            def work_presenters
              @work_presenters ||= work.try(:work_presenters) || []
            end
        end
      end
    end
  end
end
