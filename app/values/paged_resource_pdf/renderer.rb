class PagedResourcePDF
  class Renderer
    attr_reader :paged_resource_pdf, :path
    delegate :manifest_builder, :paged_resource, to: :paged_resource_pdf
    def initialize(paged_resource_pdf, path)
      @paged_resource_pdf = paged_resource_pdf
      @path = Pathname.new(path.to_s)
    end

    def render # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      CoverPageGenerator.new(paged_resource_pdf).apply(prawn_document)
      canvas_downloaders.each_with_index do |downloader, index|
        prawn_document.start_new_page layout: downloader.layout if
          index.positive?
        page_size = [Canvas::LETTER_WIDTH, Canvas::LETTER_HEIGHT]
        page_size.reverse! unless downloader.portrait?
        prawn_document.image(downloader.download,
                             width: downloader.width,
                             height: downloader.height,
                             fit: page_size)
      end
      apply_outline
      FileUtils.mkdir_p(path.dirname)
      prawn_document.render_file(path)
      File.open(path)
    end

    def canvas_images
      @canvas_images ||=
        manifest_builder.canvases.flat_map(&:images).map do |x|
          Canvas.new(x)
        end
    end

    private

      def canvas_downloaders
        @canvas_images ||= canvas_images.map do |image|
          CanvasDownloader.new(image, quality: paged_resource_pdf.quality)
        end
      end

      def apply_outline
        OutlineApplier.new(logical_order).apply(prawn_document)
      end

      def logical_order
        paged_resource.logical_order_object
      end

      def prawn_document
        @prawn_document ||= Prawn::Document.new(prawn_options)
      end

      def prawn_options
        default_options = { margin: 0 }
        if canvas_downloaders.first
          default_options[:page_layout] = canvas_downloaders.first.layout
        end
        default_options.merge(metadata)
      end

      def metadata
        {
          info: metadata_hash
        }
      end

      def metadata_hash # rubocop:disable Metrics/AbcSize
        result =
          manifest_metadata.each_with_object({}) do |entry, hsh|
            hsh[entry["label"].to_sym] = Array(entry["value"]).join(", ")
          end
        result[:Title] = Array(paged_resource.title).join(", ") if
          paged_resource.title
        if paged_resource.description
          result[:Description] =
            Array(paged_resource.description).join(", ")
        end
        result
      end

      def manifest_metadata
        @manifest_metadata ||=
          ManifestBuilder::MetadataBuilder \
          .new(paged_resource) \
          .apply(IIIF::Presentation::Manifest.new).metadata
      end
  end
end