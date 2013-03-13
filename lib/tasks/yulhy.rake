#http://viget.com/extend/protip-passing-parameters-to-your-rake-tasks
#TODO after code4lib
#https://github.com/projecthydra/active_fedora/wiki/Getting-Started:-Console-Tour
#1)create oid/cid/znum/parent datastream 2) create models and test
#rack security update

#todo 3/12/13 - compound to complex bug, create simple and child models, fill in Active fedora
namespace :yulhy do
  desc "ingest from ladybird"
  task :ingest do
    puts "Running ladybird ingest"
	puts "requirement: root of share must be 'ladybird'"
    #client = TinyTds::Client.new(:username => 'pamojaReader',:password => 'plQ(*345',:host => 'blues.library.yale.edu',:database => 'pamoja')
    @@client = TinyTds::Client.new(:username => 'pamojaWriter',:password => 'QPl478(^%',:host => 'blues.library.yale.edu',:database => 'pamoja')
    puts "connection to db OK? #{@@client.active?}"
    if @@client.active? == false
      abort("TASK ABORTED: could not connect to db")
    end
	@mountroot = "/home/ermadmix/libshare/"
	puts "batch mounted as " + @mountroot
	@cnt=0
    processoids()
    @@client.close
  end

  def processoids()
	@cnt += 1
	puts @cnt
    result = @@client.execute("select top 1 hpid,oid,cid,pid,contentModel from dbo.hydra_publish where dateHydraStart is null and dateReady is not null and _oid=0 order by date")
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
	puts "processing oid: #{i}"  
	update = @@client.execute(%Q/update dbo.hydra_publish set dateHydraStart=GETDATE() where hpid=#{i["hpid"]}/)
	update.do
	begin  
	  if i["contentModel"] == "complex"
	    #process_complex(i)
	  elsif i["contentModel"] =="simple"
        process_simple(i)	  
      else	
        processerror(i,"content model: #{i["contentModel"]} not instantiated")	
	  end
	rescue Exception => msg
      processerror(i,msg)
	end	
	update = @@client.execute(%Q/update dbo.hydra_publish set dateHydraEnd=GETDATE() where hpid=#{i["hpid"]}/)
	update.do
  end

  def processerror(i,errormsg)
    linenum = errormsg.backtrace[0].split(':')[1]
	dberror = "[#{linenum}] #{errormsg}"
    puts "error for oid: #{i["oid"]} errormsg: #{dberror}"
	#puts %Q/insert into dbo.hydra_publish_error (hpid,date,oid,error) values (#{i["hpid"]},GETDATE(),#{i["oid"]},"#{errormsg}") select @@identity/
    ehid = @@client.execute(%Q/insert into dbo.hydra_publish_error (hpid,date,oid,error) values (#{i["hpid"]},GETDATE(),#{i["oid"]},"#{dberror}")/)
	ehid.insert
	puts "finished processing error"
  end
  def processmsg(i,errormsg)
    puts "error for oid: #{i["oid"]} errormsg: #{errormsg}"
	#puts %Q/insert into dbo.hydra_publish_error (hpid,date,oid,error) values (#{i["hpid"]},GETDATE(),#{i["oid"]},"#{errormsg}") select @@identity/
    ehid = @@client.execute(%Q/insert into dbo.hydra_publish_error (hpid,date,oid,error) values (#{i["hpid"]},GETDATE(),#{i["oid"]},"#{errormsg}")/)
	ehid.insert
	puts "finished processing error"
  end

  def process_complex(i)          
    obj = ComplexParent.new  ##TODO create CompoundParent model 
	obj.label = ("oid:" << i["oid"]  << " cid:" << i["cid"])
    files = @@client.execute(%Q/select type,pathHTTP,pathUNC,md5 from dbo.hydra_publish_path where hpid=#{i["hpid"]}/)
    files.each do |file|
	  digest = Digest::MD5.hexdigest(File.read(pathUNC))
	  if digest != md5
	    processerror(i,"failed checksum for #{pathUNC}")
		return
	  end	
	  if file["type"] == "mods"
        #TODO obj.createdatastream
      elsif file["type"] == "access"
        #TODO obj.createdatastream
      elsif file["type"] =="rights"
        #TODO createdatatream
      end
	end
	obj.save
	update = @@client.execute(%Q/update dbo.hydra_publish set hydraID=#{obj.pid} where hpid=#{i["hpid"]}/)
    process_children(i,obj.pid)
  end
  
  def process_simple(i)
    #obj = Simple.new  ##TODO create Simple model 
	#obj.label = ("oid:" << i["oid"] << " cid:" << i["cid"])
    files = @@client.execute(%Q/select type,pathHTTP,pathUNC,md5 from dbo.hydra_publish_path where hpid=#{i["hpid"]}/)
    begin
	files.each do |file|
      puts "file: #{file}"
	  md5 = file["md5"]
      path = file["pathUNC"]	
      if file["type"] == "xml metadata"
        #TODO obj.createdatastream
      elsif file["type"] == "xml access"
        #TODO obj.createdatastream
      elsif file["type"] =="xml rights"
        #TODO createdatatream
	  elsif file["type"] == "tif"
        #TODO obj.createdatastream
		realpath = @mountroot + path[path.rindex('ladybird'),path.length].gsub(/\\/,'/')
	    puts "path: #{realpath}"
		if File.new(realpath).size == 0 
		  files.cancel
		  processmsg(i,%Q/filesize 0 for #{file["type"]}/)
          return
		end  
	    digest = Digest::MD5.hexdigest(File.read(realpath))
		puts "digest #{digest}"
	    if digest != md5
	      files.cancel
		  processmsg(i,%Q/failed checksum for #{file["type"]}/)
          return
        end 	
      elsif file["type"] =="jp2"
        #TODO createdatatream
		realpath = @mountroot + path[path.rindex('ladybird'),path.length].gsub(/\\/,'/')
	    puts "path: #{realpath}"
		if File.new(realpath).size == 0 
		  files.cancel
		  processmsg(i,%Q/filesize 0 for #{file["type"]}/)
          return
		end
	    digest = Digest::MD5.hexdigest(File.read(realpath))
		puts "digest #{digest}"
	    if digest != md5
	      files.cancel
		  processmsg(i,%Q/failed checksum for #{file["type"]}/)
          return
        end 
      elsif file["type"] =="jpg"
        #TODO createdatatream
        realpath = @mountroot + path[path.rindex('ladybird'),path.length].gsub(/\\/,'/')
	    puts "path: #{realpath}"
		if File.new(realpath).size == 0 
		  files.cancel
		  processmsg(i,%Q/filesize 0 for #{file["type"]}/)
          return
		end
	    digest = Digest::MD5.hexdigest(File.read(realpath))
		puts "digest #{digest}"
	    if digest != md5
	      files.cancel
		  processmsg(i,%Q/failed checksum for #{file["type"]}/)
          return
        end 		
      end
	end
	rescue Exception => msg
	  files.cancel
	  processerror(i,msg)
	end
	#obj.save
	#update = @@client.execute(%Q/update dbo.hydra_publish set hydraID=#{obj.pid} where hpid=#{i["hpid"]}/)
  end
  
  def process_children(i,ppid)
    result = @@client.execute("select bhid,oid,cid from dbo.bagHydra where dateHydraStart is null and _oid=#{i["oid"]} order by date")
    result.each { |j| 
		update = @@client.execute(%Q/update dbo.hydra_publish set dateHydraStart=GETDATE() where hpid=#{j["hpid"]}/)
        process_child(i,j,ppid) 
		update = @@client.execute(%Q/update dbo.hydra_publish set dateHydraEnd=GETDATE() where hpid=#{j["hpid"]}/)
    }  
  end

  def process_child(i,j,ppid)
    obj = CompoundChild.new  ##TODO create Compound child model 
	obj.label = ("oid:" << j["oid"] << " cid:" << j["cid"])
    files = @@client.execute(%Q/select type,pathHTTP,pathUNC,md5 from dbo.hydra_publish where hpid=#{j["hpid"]}/)
    files.each do |file|
	  digest = Digest::MD5.hexdigest(File.read(pathUNC))
	  if digest != md5
	    processerror(i,"failed checksum for #{pathUNC}")
		return
	  end
      if file["type"] == "mods"
        #TODO obj.createdatastream
      elsif file["type"] == "access"
        #TODO obj.createdatastream
      elsif file["type"] =="rights"
        #TODO createdatatream
	  elsif file["type"] == "tif"
        #TODO obj.createdatastream
      elsif file["type"] =="jp2"
        #TODO createdatatream
      elsif file["type"] =="jpeg"
        #TODO createdatatream	
      end
	end
	obj.add_relationship(:isMemberOf,i)
	zindex = @@client.execute(%Q/select top 1 _zindex from dbo.c#{j["cid"]} where oid=#{j["oid"]}/)
    parent = ppid
	#DODO - create admin_metadata w/znumber and parent
	obj.save
	update = @@client.execute(%Q/update dbo.hydra_publish set hydraID=#{obj.pid} where hpid=#{j["hpid"]}/)	
  end
  def validatechecksum(i,file)
    begin
	md5 = file["md5"]
    path = file["pathUNC"]
    realpath = @mountroot + path[path.rindex('ladybird'),path.length].gsub(/\\/,'/')
	puts "path: #{realpath}"
	digest = Digest::MD5.hexdigest(File.read(realpath))
	if digest != md5
	  return 1
	else
	  return 0
	end
    rescue Exception => msg
	  linenum = errormsg.backtrace[0].split(':')[1]
	  dberror = "[#{linenum}] #{errormsg}"
      puts "error for oid: #{i["oid"]} errormsg: #{dberror}"
	  return 2
    end	  
  end
    
end