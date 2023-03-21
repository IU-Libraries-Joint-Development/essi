# unmodified from Hydra::Works
module Extensions
  module Hydra::Works
    module CharacterizationService
      module Precharacterization

        # Get given source into form that can be passed to Hydra::FileCharacterization
        # Use Hydra::FileCharacterization to extract metadata (an OM XML document)
        # Get the terms (and their values) from the extracted metadata
        # Assign the values of the terms to the properties of the object
        def characterize
          content = source_to_content
          extracted_md = extract_metadata(content)
          terms = parse_metadata(extracted_md)
          store_metadata(terms)
        end
      end
    end
  end
end
