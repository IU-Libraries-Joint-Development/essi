desc "clean orphan filesets"
namespace :essi do
  task clean_orphan_filesets: :environment do
    logger = Logger.new(Rails.root.join("log", "clean_orphan_filesets.log"))
    logger.info "Cleaning orphan filesets"
    date_range = "1900-01-01T01:01:01Z TO #{(Time.now - 7.days).strftime('%Y-%m-%dT%H:%M:%SZ')}"
    orphans = FileSet.search_with_conditions("collection_branding_bsi:false AND parented_bsi:false AND system_create_dtsi:[#{date_range}]", rows: 10_000)
    logger.info "Orphans count: #{orphans.size}"
    orphans.each_with_index do |orphan, index|
      logger.info "Processing id #{orphan.id}, #{index+1}/#{orphans.size}"
      begin
        file_set = FileSet.find(orphan.id)
        attributes = file_set.attributes.select { |k,v| v.present? }
        to_solr = file_set.to_solr
        if to_solr['parented_bsi']
          logger.info("#{file_set.id} should be parented, saving to update solr")
          file_set.save!
        elsif to_solr['collection_branding_bsi']
          logger.info("#{file_set.id} should be collection branding, saving to update solr")
          file_set.save!
        else
          logger.info("Confirmed orphan FileSet, destroying: #{attributes}")
          file_set.destroy
        end
      rescue => error
        logger.error "Failure processing id #{orphan.id} #{attributes if defined?(attributes)}"
        logger.error error.inspect
      end
    end
    logger.info "Completed"
  end
end
