module PrederivationHelper
  def work_root_name(filename)
    filename.split('/').last.split('-').first
  end

  def derivatives_folder_for(filename, type: '')
    derivatives_folder = ESSI.config.dig(:essi, :derivatives_folder)
    return false unless derivatives_folder
    folders = Array.wrap(derivatives_folder)
    folders << type.downcase if path_includes_type?
    folders << work_root_name(filename) if path_includes_work_root_name?
    File.join(derivatives_folder, type.downcase, work_root_name(filename))
  end

  def pre_derived_file(filename, type: '', suffix: 'xml')
    Rails.logger.info "Checking for a Pre-derived #{type} folder."
    derivatives_folder = derivatives_folder_for(filename, type: type)
    return false unless derivatives_folder && Dir.exists?(derivatives_folder.to_s)

    Rails.logger.info "Checking for a Pre-derived #{type} file."
    if file_includes_type?
      pre_derived_filename = "#{File.basename(filename, '.*')}-#{type.downcase}.#{suffix}"
    else
      pre_derived_filename = "#{File.basename(filename, '.*')}.#{suffix}"
    end
    pre_derived_file = File.join(derivatives_folder, pre_derived_filename)
    return false unless File.exist?(pre_derived_file)

    Rails.logger.info "Using Pre-derived #{type} file."
    pre_derived_file
  end

  def path_includes_type?
    ESSI.config.dig(:essi, :derivatives_type_subfolder)
  end

  def path_includes_work_root_name?
    ESSI.config.dig(:essi, :derivatives_work_subfolder)
  end

  def file_includes_type?
    ESSI.config.dig(:essi, :derivatives_type_suffix)
  end
end
