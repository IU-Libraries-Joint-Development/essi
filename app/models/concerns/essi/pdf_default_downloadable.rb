module ESSI
  module PDFDefaultDownloadable
    def self.included(base)
      base.class_eval do
        after_initialize do |work|
          if work.respond_to?(:pdf_state) && work.pdf_state.blank?
            begin
              work.pdf_state = 'downloadable'
            rescue ArgumentError
              work.pdf_state = ['downloadable']
            end
          end
        end
      end
    end
  end
end
