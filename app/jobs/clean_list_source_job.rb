class CleanListSourceJob < ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # Cleans up extraneous list_source resources that were left behind when adding a file to an existing work
  # when using the OrderedMembersActor.
  def perform(work)
    sparql = ""
    list_source = work.list_source
    # Build list of resources that need to be cleaned up, leaving out the active resources.
    rm_uris = (list_source.ldp_source.graph.subjects - list_source.nodes_ids.to_a) - [list_source.uri]
    rm_uris.each do |uri|
      # Build SQARQL delete commands for each predicate of each resource to be cleaned.
      rm_statements = list_source.ldp_source.graph.statements.filter { |s| s.subject == uri }
      rm_statements.each do |s|
        pattern = "<#{s.subject}> <#{s.predicate}> ?change ."
        sparql << "DELETE { #{pattern} }\n  WHERE { #{pattern} } ;\n"
      end
    end
    Rails.logger.debug { "Cleaning up leftover list_source parts for #{list_source.uri.to_s}. SPARQL UPDATE:\n#{sparql}" }
    # Send directly to Fedora. See ActiveFedora::SparqlInsert
    result = ActiveFedora.fedora.connection.patch(list_source.uri, sparql,  "Content-Type" => "application/sparql-update")
    return true if result.status == 204
    raise "Problem updating #{result.status} #{result.body}"
  end
end