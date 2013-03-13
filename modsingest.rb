require '/home/ermadmix/hy_projs/yul_hydra_head2/config/environment.rb'

tempdir = '/home/ermadmix/'
obj = ComplexParent.new
obj.label = "oid:" + "12345" + " cid:" + "1"

modsfile = tempdir + 'mods.xml'
open(modsfile, 'wb') do |file|
  file << open('http://lbdev.library.yale.edu/xml_metadata.aspx?a=s_lib_ladybird&b=E8F3FF02-A65A-4A20-B7B1-A9E35969A0B7&c=10592580').read
end
file = File.new(modsfile)
obj.add_file_datastream(file,:controlGroup=>'M',:mimeType=>'text/xml',:dsid=>'descMetadata')
File.delete(modsfile)

#file = File.new('/home/ermadmix/seedfile.txt')

tiffile = File.new('/home/ermadmix/libshare/ladybird/project25/publish/BAG/10592589/data/4005429a.tif')
jpgfile = File.new('/home/ermadmix/libshare/ladybird/project25/publish/DL/10592589/4005429a.jpg')
jp2file = File.new('/home/ermadmix/libshare/ladybird/project25/publish/DL/10592589/4005429a.jp2')

obj.add_file_datastream(tiffile,:dsid=>'tif',:mimeType=>"image/tiff", :controlGroup=>'M',:checksumType=>'MD5')
obj.add_file_datastream(jpgfile,:dsid=>'jpg',:mimeType=>"image/jpg", :controlGroup=>'M',:checksumType=>'MD5')
obj.add_file_datastream(jp2file,:dsid=>'jp2',:mimeType=>"image/jp2", :controlGroup=>'M',:checksumType=>'MD5')
#obj.add_file_datastream(jpgfile,:dsid=>'jpg',:label=>'jpg oid',:mimeType=>"image/jpg", :controlGroup=>'M',:checksumType=>'MD5',:checksum=>'b607a3cdd700a3148b5cbeb83ef39711')

#obj.save

#ds = obj.create_datastream('ActiveFedora::Datastream','tif',:mimeType=>'image/tiff',:controlGroup=>'M',:dsLabel=>'TIFF oid #',:dsLocation=>'http://lbfiles.library.yale.edu/10590509.tif')
#obj.add_datastream(ds)
#ds = obj.create_datastream('ActiveFedora::Datastream','jpg',:mimeType=>'image/jpg',:controlGroup=>'M',:dsLabel=>'JPG oid #',:dsLocation=>'http://lbfiles.library.yale.edu/10590509.jpg')
#obj.add_datastream(ds)
#ds = obj.create_datastream('ActiveFedora::Datastream','jp2',:mimeType=>'image/jp2',:controlGroup=>'M',:dsLabel=>'jp2 oid #',:dsLocation=>'http://lbfiles.library.yale.edu/10590509.jp2')
#obj.add_datastream(ds)

obj.save
puts obj.pid