#http://viget.com/extend/protip-passing-parameters-to-your-rake-tasks
#TODO after code4lib
#https://github.com/projecthydra/active_fedora/wiki/Getting-Started:-Console-Tour
#1)create oid/cid/znum/parent datastream 2) create models and test
#rack security update

#todo 3/12/13 - compound to complex bug, create simple and child models, fill in Active fedora
require '/home/ermadmix/hy_projs/yul_hydra_head2/config/environment.rb'
namespace :yulhy do
  desc "ingest from ladybird"
  task :ingest do
    puts "Running ladybird ingest"
	puts "requirement: root of share must be 'ladybird'"
    #client = TinyTds::Client.new(:username => 'pamojaReader',:password => 'plQ(*345',:host => 'blues.library.yale.edu',:database => 'pamoja')
    @@client = TinyTds::Client.new(:username => 'pamojaWriter',:password => 'QPl478(^%',:host => 'blues.library.yale.edu',:database => 'pamoja')
    puts "client1 connection to db OK? #{@@client.active?}"
    if @@client.active? == false
      abort("TASK ABORTED: client1 could not connect to db")
    end
	@@client2 = TinyTds::Client.new(:username => 'pamojaWriter',:password => 'QPl478(^%',:host => 'blues.library.yale.edu',:database => 'pamoja')
    puts "client2 connection to db OK? #{@@client.active?}"
    if @@client2.active? == false
      abort("TASK ABORTED: client2 could not connect to db")
    end
	@mountroot = "/home/ermadmix/libshare/"
	puts "batch mounted as " + @mountroot
	@tempdir = "/home/ermadmix/"
	puts "temp directory" + @tempdir
	@cnt=0
    processoids()
    @@client.close
  end

  def processoids()
	@cnt += 1
	puts @cnt
    result = @@client.execute("select top 1 hpid,oid,cid,pid,contentModel,_oid,zindex from dbo.hydra_publish where dateHydraStart is null and dateReady is not null and _oid=0 order by date")
    result.fields.to_s
	if result.affected_rows == 0
      @@client.close
      abort("finished, no more baghydra rows to process")
    else 
      result.each do |i|
        begin	  
          processparentoid(i)
        rescue Exception => msg
          processerror(i,msg)
        end		  
      end
	  if @cnt > 30 
	    abort("prevent infinite loop")
	  end	  
      processoids()
    end
  end
  
  def processparentoid(i)
	puts "processing top level oid: #{i}"  
	update = @@client.execute(%Q/update dbo.hydra_publish set dateHydraStart=GETDATE() where hpid=#{i["hpid"]}/)
	update.do
	begin  
	  if i["contentModel"] == "complex"
	    process_complex(i)
	  elsif i["contentModel"] =="simple"
        process_simple(i,"simple","")	  
      else	
        processerror(i,"content model: #{i["contentModel"]} not instantiated")	
	  end
	rescue Exception => msg
      processerror(i,msg)
	end	
	update = @@client.execute(%Q/update dbo.hydra_publish set dateHydraEnd=GETDATE() where hpid=#{i["hpid"]}/)
	update.do
  end

  #ERJ error routine for exceptions 
  def processerror(i,errormsg)
    linenum = errormsg.backtrace[0].split(':')[1]
	dberror = "[#{linenum}] #{errormsg}"
    puts "error for oid: #{i["oid"]} errormsg: #{dberror}"
	#puts "STACK:" + errormsg.backtrace.to_s
	ehid = @@client.execute(%Q/insert into dbo.hydra_publish_error (hpid,date,oid,error) values (#{i["hpid"]},GETDATE(),#{i["oid"]},"#{dberror}")/)
	ehid.insert
  end
  #ERJ error routine for message driven errors (no exceptions) 
  def processmsg(i,errormsg)
    puts "error for oid: #{i["oid"]} errormsg: #{errormsg}"
	ehid = @@client.execute(%Q/insert into dbo.hydra_publish_error (hpid,date,oid,error) values (#{i["hpid"]},GETDATE(),#{i["oid"]},"#{errormsg}")/)
	ehid.insert
  end

  def process_complex(i) 
    puts "complex oid: #{i}"  
    obj = ComplexParent.new 
	obj.label = ("oid: #{i["oid"]}")
    files = @@client.execute(%Q/select type,pathHTTP,pathUNC,md5 from dbo.hydra_publish_path where hpid=#{i["hpid"]}/)
    metachk = 0
	accchk = 0
	rightschk = 0
	begin
	files.each do |file|
      puts %Q/file: #{file["type"]}/
	  md5 = file["md5"]
      path = file["pathUNC"]	
      if file["type"] == "xml metadata"
	    #puts %Q/url: #{file["pathHTTP"]}/
        modsfile = @tempdir + 'mods.xml'
        open(modsfile, 'wb') do |f|
          f << open(file["pathHTTP"]).read
        end
        ff = File.new(modsfile)
        obj.add_file_datastream(ff,:controlGroup=>'M',:mimeType=>'text/xml',:dsid=>'descMetadata')
        File.delete(modsfile)
		metachk = 1
      elsif file["type"] == "xml access"
        #puts %Q/url: #{file["pathHTTP"]}/
        accessfile = @tempdir + 'access.xml'
        open(accessfile, 'wb') do |f|
          f << open(file["pathHTTP"]).read
        end
        ff = File.new(accessfile)
        obj.add_file_datastream(ff,:controlGroup=>'M',:mimeType=>'text/xml',:dsid=>'accessMetadata')
        File.delete(accessfile)
		accchk = 1
      elsif file["type"] =="xml rights"
        #puts %Q/url: #{file["pathHTTP"]}/
        rightsfile = @tempdir + 'rights.xml'
        open(rightsfile, 'wb') do |f|
          f << open(file["pathHTTP"]).read
        end
        ff = File.new(rightsfile)
        obj.add_file_datastream(ff,:controlGroup=>'M',:mimeType=>'text/xml',:dsid=>'rightsMetadata')
        File.delete(rightsfile)
		rightschk = 1
      end
	end
	rescue Exception => msg
	  files.cancel
	  processerror(i,msg)
	  return
	end
    missingds = ""
	missingds += "no descMetadata " if metachk == 0
	missingds += "no accessMetadata " if accchk == 0
	missingds += "no rightsMetadata " if rightschk == 0
	if missingds.size > 0
	  processmsg(i,missingds)
	  return
	end
    obj.oid = i["oid"]
	obj.cid = i["cid"]
	obj.projid = i["pid"]
	obj.zindex = i["zindex"]
	obj.parentoid = i["_oid"]
	begin
	  result = @@client.execute(%Q/select max(zindex) as total from dbo.hydra_publish where _oid = #{i["oid"]}/)
	  result.each do |i|
	    obj.ztotal =  i["total"]
	  end
	  obj.save
	rescue Exception => msg
	  unless result.nil? 
		result.cancel
	  end
      processerror(i,msg)
	  return
    end
	puts "PID #{obj.pid} sucessfully created for #{i["oid"]}"
	update = @@client.execute(%Q/update dbo.hydra_publish set hydraID='#{obj.pid}' where hpid=#{i["hpid"]}/)
    update.do
	process_children(i,obj.pid)
  end
  
  def process_simple(i,cm,ppid)
    obj = nil 
	if cm == "simple"
	  puts "simple oid: #{i}"
      obj = Simple.new
	elsif cm == "child"
	  puts "child oid: #{i}"
	  obj = ComplexChild.new
	end  
	obj.label = ("oid: #{i["oid"]}")
    files = @@client.execute(%Q/select type,pathHTTP,pathUNC,md5 from dbo.hydra_publish_path where hpid=#{i["hpid"]}/)
    metachk = 0
	accchk = 0
	rightschk = 0
	tifchk = 0
	jp2chk = 0
	jpgchk = 0
	begin
	files.each do |file|
      puts %Q/file: #{file["type"]}/
	  md5 = file["md5"]
      path = file["pathUNC"]	
      if file["type"] == "xml metadata"
	    #puts %Q/url: #{file["pathHTTP"]}/
        modsfile = @tempdir + 'mods.xml'
        open(modsfile, 'wb') do |f|
          f << open(file["pathHTTP"]).read
        end
        ff = File.new(modsfile)
        obj.add_file_datastream(ff,:controlGroup=>'M',:mimeType=>'text/xml',:dsid=>'descMetadata')
        File.delete(modsfile)
		metachk = 1
      elsif file["type"] == "xml access"
        #puts %Q/url: #{file["pathHTTP"]}/
        accessfile = @tempdir + 'access.xml'
        open(accessfile, 'wb') do |f|
          f << open(file["pathHTTP"]).read
        end
        ff = File.new(accessfile)
        obj.add_file_datastream(ff,:controlGroup=>'M',:mimeType=>'text/xml',:dsid=>'accessMetadata')
        File.delete(accessfile)
		accchk = 1
      elsif file["type"] =="xml rights"
        #puts %Q/url: #{file["pathHTTP"]}/
        rightsfile = @tempdir + 'rights.xml'
        open(rightsfile, 'wb') do |f|
          f << open(file["pathHTTP"]).read
        end
        ff = File.new(rightsfile)
        obj.add_file_datastream(ff,:controlGroup=>'M',:mimeType=>'text/xml',:dsid=>'rightsMetadata')
        File.delete(rightsfile)
		rightschk = 1
	  elsif file["type"] == "tif"
		realpath = @mountroot + path[path.rindex('ladybird'),path.length].gsub(/\\/,'/')
	    #puts "path: #{realpath}"
		if File.new(realpath).size == 0 
		  files.cancel
		  processmsg(i,%Q/filesize 0 for #{file["type"]}/)
          return
		end  
	    digest = Digest::MD5.hexdigest(File.read(realpath))
		#puts "digest #{digest}"
	    if digest != md5
	      files.cancel
		  processmsg(i,%Q/failed checksum for #{file["type"]}/)
          return
        end
		tiffile = File.new(realpath)
        obj.add_file_datastream(tiffile,:dsid=>'tif',:mimeType=>"image/tiff", :controlGroup=>'M',:checksumType=>'MD5')
		tifchk = 1  
	  elsif file["type"] =="jp2"
		realpath = @mountroot + path[path.rindex('ladybird'),path.length].gsub(/\\/,'/')
	    #puts "path: #{realpath}"
		if File.new(realpath).size == 0 
		  files.cancel
		  processmsg(i,%Q/filesize 0 for #{file["type"]}/)
          return
		end
	    digest = Digest::MD5.hexdigest(File.read(realpath))
		#puts "digest #{digest}"
	    if digest != md5
	      files.cancel
		  processmsg(i,%Q/failed checksum for #{file["type"]}/)
          return
        end
        jp2file = File.new(realpath)
        obj.add_file_datastream(jp2file,:dsid=>'jp2',:mimeType=>"image/jp2", :controlGroup=>'M',:checksumType=>'MD5')
        jp2chk = 1
	  elsif file["type"] =="jpg"
        realpath = @mountroot + path[path.rindex('ladybird'),path.length].gsub(/\\/,'/')
	    #puts "path: #{realpath}"
		if File.new(realpath).size == 0 
		  files.cancel
		  processmsg(i,%Q/filesize 0 for #{file["type"]}/)
          return
		end
	    digest = Digest::MD5.hexdigest(File.read(realpath))
		#puts "digest #{digest}"
	    if digest != md5
	      files.cancel
		  processmsg(i,%Q/failed checksum for #{file["type"]}/)
          return
        end
        jpgfile = File.new(realpath)
        obj.add_file_datastream(jpgfile,:dsid=>'jpg',:mimeType=>"image/jpg", :controlGroup=>'M',:checksumType=>'MD5')   		
        jpgchk = 1
	  end
	end
	rescue Exception => msg
	  files.cancel
	  processerror(i,msg)
	  return
	end
	missingds = ""
	missingds += "no descMetadata " if metachk == 0
	missingds += "no accessMetadata " if accchk == 0
	missingds += "no rightsMetadata " if rightschk == 0
	missingds += "no tif " if tifchk == 0
	missingds += "no jp2 " if jp2chk == 0
	missingds += "no jpg " if jpgchk == 0
	if missingds.size > 0
	  processmsg(i,missingds)
	  return
	end  
	obj.oid = i["oid"]
	obj.cid = i["cid"]
	obj.projid = i["pid"]
	obj.zindex = i["zindex"]
	obj.parentoid = i["_oid"]
	begin
	  if cm == "child"
	    pid_uri = "info:fedora/#{ppid}"
	    obj.add_relationship(:is_member_of,pid_uri)
	  end
	  obj.save
	rescue Exception => msg
      processerror(i,msg)
	  return
    end	  
	puts "PID #{obj.pid} sucessfully created for #{i["oid"]}"
	update = @@client.execute(%Q/update dbo.hydra_publish set hydraID='#{obj.pid}' where hpid=#{i["hpid"]}/)
	update.do
  end
  
  def process_children(i,ppid)
    puts "process_children for #{ppid}"
	#ERJ note using client2 for children iteration
    result = @@client2.execute("select hpid,oid,cid,pid,contentModel,_oid,zindex from dbo.hydra_publish where dateHydraStart is null and _oid=#{i["oid"]} order by date")
    result.each { |j|
      begin 	
	    update = @@client.execute(%Q/update dbo.hydra_publish set dateHydraStart=GETDATE() where hpid=#{j["hpid"]}/)
        update.do
		#if j["oid"] == 10590509
          process_simple(j,"child",ppid)
		#else
	    #  puts %Q/bypass processing child #{j["hpid"]} #{j["oid"]}/ 
        #end			
	    update = @@client.execute(%Q/update dbo.hydra_publish set dateHydraEnd=GETDATE() where hpid=#{j["hpid"]}/)
	    update.do
	  rescue Exception => msg
	    unless update.nil? 
		  update.cancel
		end
	    unless result.nil?
		  result.cancel
		end
	    processerror(i,msg)
	    return#for testing
	  end
    }  
  end
end