module ESSI
  module PagedResourceFormBehavior
    extend ActiveSupport::Concern
    # Add behaviors that make this work type unique

    included do
      self.terms += [:holding_location, :publication_place, :viewing_direction, :viewing_hint, :allow_pdf_download]
      # self.terms -= [:allow_pdf_download]
      # add form to views/records/edit_fields/_allow_pdf_download.html.erb
      # add the form partial to hyrax/base/_form_visibility_component.html.erb (might not be the right partial)
      # https://samvera.github.io/customize-metadata-generate-work-type.html
    end
  end
end
