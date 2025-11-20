# modified from Hydra::Works
module Extensions
  module Hydra::Works
    module CharacterizationService
      module Precharacterization
        include PrederivationHelper

        # Get given source into form that can be passed to Hydra::FileCharacterization
        # Use Hydra::FileCharacterization to extract metadata (an OM XML document)
        # Get the terms (and their values) from the extracted metadata
        # Assign the values of the terms to the properties of the object
        def characterize
          file_name = File.basename(source)
          existing_file = precharacterization(file_name)
          if existing_file
            extracted_md = File.read(existing_file)
          else
            content = source_to_content
            extracted_md = extract_metadata(content)
          end
          terms = parse_metadata(extracted_md)
          store_metadata(terms)
        end
  
        def precharacterization(filename)
          pre_derived_file(filename, type: 'characterization')
        end
      end
    end
  end
end
