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
          existing_file = precharacterization(source)
          if existing_file
            extracted_md = File.read(existing_file)
          else
            content = source_to_content
            extracted_md = extract_metadata(content)
          end
          terms = parse_metadata(extracted_md)
          terms = revise_metadata(terms)
          store_metadata(terms)
        end

        # for pyramidal tiffs characterized at multiple resolutions, use max
        def revise_metadata(terms)
          [:width, :height].each do |k|
            terms[k] = [terms[k].map(&:to_i).max.to_s] if terms[k]&.size > 1
          end
          terms
        end
  
        def precharacterization(filename)
          pre_derived_file(filename, type: 'characterization')
        end
      end
    end
  end
end
