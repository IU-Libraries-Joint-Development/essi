class CleanListSourceJob < ApplicationJob
  queue_as 'important'

  # Cleans up extraneous list_source resources that were left behind when adding a file to an existing work when using OrderedMembersActor.
  def perform(work, batch_size = 100)
    # raise ArgumentError, "batch size must be positive" unless batch_size > 0
    list_source = work.list_source
    # Build list of resources that need to be cleaned up, leaving out the active resources.
    graph = list_source.ldp_source.graph
    rm_uris = (graph.subjects - list_source.nodes_ids.to_a) - [list_source.uri]
    ls_statements = graph.statements
    until rm_uris.empty?
      Rails.logger.info { "Cleaning up #{rm_uris.length} leftover list_source parts for #{list_source.uri.to_s}." }
      sparql = ""
      rm_uris.slice!(0, batch_size).each do |uri|
        # Build SPARQL delete commands for each predicate of each resource to be cleaned.
        rm_statements = ls_statements.filter { |s| s.subject == uri }
        rm_statements.each do |s|
          pattern = "<#{s.subject}> <#{s.predicate}> ?change ."
          sparql << "DELETE { #{pattern} }\n  WHERE { #{pattern} } ;\n"
        end
      end
      Rails.logger.debug { "SPARQL UPDATE:\n#{sparql}" }
      # Send directly to Fedora. See ActiveFedora::SparqlInsert
      result = ActiveFedora.fedora.connection.patch(list_source.uri, sparql,  "Content-Type" => "application/sparql-update") do |req|
        req.options.timeout = 600
      end
      raise "Problem updating #{list_source.uri.to_s} #{result.status} #{result.body}" unless result.status == 204
    end
    return true
  end
end