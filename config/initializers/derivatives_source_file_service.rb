# All derivative creation uses Fedora-stored files (or not) per the application config setting
Hydra::Derivatives.source_file_service = Hydra::Derivatives::RetrieveSourceFileService if ESSI.config.dig(:essi, :store_original_files)
