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

#file = File.new('/home/ermadmix/seedfile.txt')
#obj.add_file_datastream(file,:controlGroup=>'M',:dsid=>'tif')
#obj.add_file_datastream(file,:controlGroup=>'M',:dsid=>'jpg')
#obj.add_file_datastream(file,:controlGroup=>'M',:dsid=>'jp2')

#obj.save

#ds = obj.create_datastream('ActiveFedora::Datastream','tif',:mimeType=>'image/tiff',:controlGroup=>'M',:dsLabel=>'TIFF oid #',:dsLocation=>'http://lbfiles.library.yale.edu/10590509.tif')
#obj.add_datastream(ds)
#ds = obj.create_datastream('ActiveFedora::Datastream','jpg',:mimeType=>'image/jpg',:controlGroup=>'M',:dsLabel=>'JPG oid #',:dsLocation=>'http://lbfiles.library.yale.edu/10590509.jpg')
#obj.add_datastream(ds)
#ds = obj.create_datastream('ActiveFedora::Datastream','jp2',:mimeType=>'image/jp2',:controlGroup=>'M',:dsLabel=>'jp2 oid #',:dsLocation=>'http://lbfiles.library.yale.edu/10590509.jp2')
#obj.add_datastream(ds)

obj.save
puts obj.pid
