module ESSI
  class GeneratePdfService
    # Generate PDFs for download
    # @param [SolrDocument] resource
    def initialize(resource)
      @resource = resource
      @file_name = "#{@resource.id}.pdf"
    end

    def generate
      file_path = create_pdf_file_path
      generate_pdf_document(file_path)

      { file_path: file_path, file_name: @file_name }
    end

    private

    def dir_path
      Rails.root.join('tmp', 'pdfs')
    end

    def create_pdf_file_path
      file_path = dir_path.join(@file_name)

      FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)
      File.delete(file_path) if File.exist?(file_path)
      file_path
    end

    def generate_pdf_document(file_path)
      Prawn::Document.generate(file_path, margin: [0, 0, 0, 0]) do |pdf|
        CoverPageGenerator.new(@resource).apply(pdf)
        create_tmp_files(pdf)
      end
    end

    def create_tmp_files(pdf)
      # TODO Use logical structure if it exists?
      sorted_files = Hyrax::SolrDocument::OrderedMembers.decorate(@resource).ordered_member_ids
      sorted_files.each.with_index(1) do |fs, i|
        pdf.start_new_page
        begin
          fs_solr = SolrDocument.find(fs)
          image_width = get_image_width(fs_solr).to_i
          raise StandardError, 'Image width unavailable' unless image_width > 0 # IIIF server call requires a positive integer value
          iiif_path_service = IIIFFileSetPathService.new(fs_solr)
          raise StandardError, 'Source image file unavailable' unless iiif_path_service.lookup_id
          uri = iiif_path_service.iiif_image_url(size: render_dimensions(image_width))
          URI.open(uri) do |file|
            page_size = [CoverPageGenerator::LETTER_WIDTH, CoverPageGenerator::LETTER_HEIGHT]
            file.binmode
            pdf.image(file, fit: page_size, position: :center, vposition: :center)
          end
        rescue => error
          Rails.logger.error "PDF page generation failed for FileSet #{fs} with #{error.class}: #{error.message}"
          pdf.text("Page #{i} generation failed")
        end
      end
    end

    # ensure not requesting greater than 100% image width, as that makes IIIF server 403
    def get_image_width(solr_doc)
      solr_doc.width || generate_width(solr_doc.id)
    end

    def render_dimensions(image_width)
      render_width = [image_width, 1024].min
      "#{render_width},"
    end

    # run characterization directly for width, then spawn normal job
    def generate_width(file_set_id)
      begin
        file_set = FileSet.find(file_set_id)
        filepath = file_set.find_or_retrieve
        terms = Hydra::Works::CharacterizationService.run(file_set.original_file, filepath)
        CharacterizeJob.perform_later(file_set, file_set.original_file.id)
      rescue
        terms = {}
      end
      terms[:width]&.first.to_i
    end
  end
end
