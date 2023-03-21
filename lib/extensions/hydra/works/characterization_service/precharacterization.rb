# modified from Hydra::Works
module Extensions
  module Hydra::Works
    module CharacterizationService
      module Precharacterization

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
          store_metadata(terms)
        end
  
        def precharacterization(filename)
          Rails.logger.info 'Checking for a Pre-derived characterization folder.'
          return false unless ESSI.config.dig(:essi, :characterization_folder)
    
          Rails.logger.info 'Checking for a Pre-derived characterization file.'
          characterization_filename = "#{File.basename(filename, '.*')}-characterization.xml"
          characterization_file = File.join(ESSI.config.dig(:essi, :characterization_folder), characterization_filename)
          return false unless File.exist?(characterization_file)
    
          Rails.logger.info 'Using Pre-derived characterization file.'
          characterization_file
        end
      end
    end
  end
end
