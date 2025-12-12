require 'nokogiri'
require 'open-uri'
require 'cgi'
require 'json'
require 'csv'
require 'logger'

logger = Logger.new('slocum_member_build.log')

namespaces = {'sparql' => 'http://www.w3.org/2001/sw/DataAccess/rf1/result',
              'dc' => "http://purl.org/dc/elements/1.1/",
              'oai_dc' => "http://www.openarchives.org/OAI/2.0/oai_dc/"
             }
ids = []

CSV.foreach('slocum_import.csv', headers: true, converters: :numeric) do |row|
  # Each row is already a CSV::Row object with hash-like access
  full_id = row['purl'].split('http://purl.dlib.indiana.edu/iudl/').last.chomp
  #puts "Processing: #{row['source']} as #{full_id}"
  ids << full_id
end

File.foreach('slocum_ids.txt') do |line|
  #ids << line.chomp
end

members_array = []
ids.each do |id|
  escaped_id = CGI.escape id
  logger.info "Importing #{id}"
  url = "https://fedora.dlib.indiana.edu/fedora/risearch?type=tuples&lang=itql&format=Sparql&query=select%20%24member%20from%20%3C%23ri%3E%20where%20%24member%20%3Cdc%3Aidentifier%3E%20'http%3A%2F%2Fpurl.dlib.indiana.edu%2Fiudl%2F#{escaped_id}' "
  resp = URI.open(url)
  xml = Nokogiri::XML(resp)
  next if xml.xpath('//sparql:member', namespaces)[0].nil?
  primary_image_pid = xml.xpath('//sparql:member', namespaces)[0].attributes["uri"].value


  member_url = "https://fedora.dlib.indiana.edu/fedora/risearch?type=tuples&lang=itql&format=Sparql&query=select%20%24child%20from%20%3C%23ri%3E%20%0Awhere%20%24child%20%3Cinfo%3Afedora%2Ffedora-system%3Adef%2Frelations-external%23hasMetadata%3E%20%3C#{CGI.escape(primary_image_pid)}%3E"

  member_resp = URI.open(member_url)

  member_xml = Nokogiri::XML(member_resp)

  member_image_pids = []
  member_xml.xpath('//sparql:child', namespaces).each do |child|
    member_image_pids << child.attributes["uri"].value.split('/').last
  end

  #member_dc_url = "https://fedora.dlib.indiana.edu/fedora/objects/#{member_image_pids[0]}/datastreams/DC/content"
  member_dc_urls = []
  member_image_pids.each do |pid|
    ds_url = "https://fedora.dlib.indiana.edu/fedora/objects/#{pid}/datastreams/DC/content"
    member_dc_urls << ds_url
  end

  member_filenames = []
  member_dc_urls.each do |member_dc_url|
    member_dc_resp = URI.open(member_dc_url)
    member_dc_xml = Nokogiri::XML(member_dc_resp)
    member_image_purl = member_dc_xml.xpath("//dc:identifier[contains(text(), 'purl.dlib')]", namespaces)
    member_filenames << member_image_purl.text.split('/').last
  end

  members_array << { 'id' => id, 'members' => member_filenames }
  sleep 1


end
puts JSON.pretty_generate(members_array)
