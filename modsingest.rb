require '/home/ermadmix/hy_projs/yul_hydra_head2/config/environment.rb'

tempdir = '/home/ermadmix/'
obj = CompoundParent.new
obj.label = "oid:" + "12345" + " cid:" + "1"

modsfile = tempdir + 'mods.xml'
open(modsfile, 'wb') do |file|
  file << open('http://lbdev.library.yale.edu/xml_metadata.aspx?a=s_lib_ladybird&b=E8F3FF02-A65A-4A20-B7B1-A9E35969A0B7&c=10592580').read
end
file = File.new(modsfile)
obj.add_file_datastream(file,:controlGroup=>'M',:mimeType=>'text/xml',:dsid=>'descMetadata')
File.delete(modsfile)
obj.save
puts obj.pid
