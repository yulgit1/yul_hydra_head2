require '/home/ermadmix/hy_projs/yul_hydra_head2/config/environment.rb'

tempdir = '/home/ermadmix/'
obj = ActiveFedora::Base.find("changeme:165")

modsfile = tempdir + 'mods.xml'
open(modsfile, 'wb') do |file|
  file << open('http://lbxml.library.yale.edu/10590519_metadata.xml').read
end
file = File.new(modsfile)
obj.add_file_datastream(file,:controlGroup=>'M',:mimeType=>'text/xml',:dsid=>'descMetadata')
obj.save
puts obj.pid

solrizer = Solrizer::Fedora::Solrizer.new
solrizer.solrize "changeme:165"
solrizer.solrize obj
