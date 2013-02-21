#http://viget.com/extend/protip-passing-parameters-to-your-rake-tasks
#TODO after code4lib
#https://github.com/projecthydra/active_fedora/wiki/Getting-Started:-Console-Tour
#1)create oid/cid/znum/parent datastream 2) create models and test
#rack security update
#errorhydra table (id, oid,error, timestamp)
#baghydra_errorhydra table (bhid,ehid)
#baghydra_paths - fields: temp storage,permanent storage, URL, MD5
namespace :yulhy do
  desc "ingest from ladybird"
  task :ingest do
    puts "Running ladybird ingest"
    #client = TinyTds::Client.new(:username => 'pamojaReader',:password => 'plQ(*345',:host => 'blues.library.yale.edu',:database => 'pamoja')
    @@client = TinyTds::Client.new(:username => 'pamojaWriter',:password => 'QPl478(^%',:host => 'blues.library.yale.edu',:database => 'pamoja')
    puts "connection to db OK? #{@@client.active?}"
    if @@client.active? == false
      abort("TASK ABORTED: could not connect to db")
    end
    processoids()
    @@client.close
  end

  def processoids()
    result = @@client.execute("select top 1 hpid,oid,cid,contentModel from dbo.hydra_publish where dateHydraStart is null and _oid=0 order by date")
    if result.affected_rows == 0
      @@client.close
      abort("finished, no more baghydra rows to process")
    else 
      result.each { |i| 
        processparentoid(i) 
      }
      #UNCOMM processoids() #recursion
    end
  end
  
  def processparentoid(i)
	puts "processing oid: #{i}"
	#UNCOMM update = @@client.execute(%Q/update dbo.hydra_publish set dateHydraStart=GETDATE() where hpid=#{i["hpid"]}/)
	if i["contentModel"] == "compound"
	  process_compound(i)
	else if i["contentModel"] =="simple"
      process_simple(i)
    else 
      processerror(i,"content model: #{i["contentModel"]} not instantiated")	
	end
	#UNCOMM update = @@client.execute(%Q/update dbo.hydra_publish set dateHydraEnd=GETDATE() where hpid=#{i["hpid"]}/)
  end

  def processerror(i,errormsg)
    puts "error for oid: #{i["oid"]} errormsg: #{errormsg}"
    #UNCOMM ehid = @@client.execute(%Q/insert into dbo.hydra_publish_error (hpid,date,oid,error) values (#{i["hpid"]},GETDATE(),#{i["oid"]},#{errormsg}) select @@identity/)
  end

  def process_compound(i)          
    obj = CompoundParent.new  ##TODO create CompoundParent model 
	obj.label = ("oid:" << i["oid"]  << " cid:" << i["cid"])
    files = @@client.execute(%Q/select type,pathHTTP,pathUNC,md5 from dbo.hydra_publish_path where hpid=#{i["hpid"]}/)
    files.each { |file|
	  digest = Digest::MD5.hexdigest(File.read(pathUNC))
	  if digest != md5
	    processerror(i,"failed checksum for #{pathUNC}")
		#TODO rollback functionality
	  end	
	  if file["type"] == "mods"
        #TODO obj.createdatastream
      else if file["type"] == "access"
        #TODO obj.createdatastream
      else if file["type"] =="rights"
        #TODO createdatatream
      end
	}
	obj.save
	#UNCOMM update = @@client.execute(%Q/update dbo.hydra_publish set hydraID=#{obj.pid} where hpid=#{i["hpid"]}/)
    process_children(i,obj.pid)
  end
  
  def process_simple(i)
    #UNCOMM update = @@client.execute(%Q/update dbo.hydra_publish set dateHydraStart=GETDATE() where hpid=#{i["hpid"]}/)
    obj = Simple.new  ##TODO create Simple model 
	obj.label = ("oid:" << i["oid"] << " cid:" << i["cid"])
    files = @@client.execute(%Q/select type,pathHTTP,pathUNC,md5 from dbo.hydra_publish_path where hpid=#{i["hpid"]}/)
    files.each { |file|
	  digest = Digest::MD5.hexdigest(File.read(pathUNC))
	  if digest != md5
	    processerror(i,"failed checksum for #{pathUNC}")
		#TODO rollback functionality
	  end
      if file["type"] == "mods"
        #TODO obj.createdatastream
      else if file["type"] == "access"
        #TODO obj.createdatastream
      else if file["type"] =="rights"
        #TODO createdatatream
	  else if file["type"] == "tif"
        #TODO obj.createdatastream
      else if file["type"] =="jp2"
        #TODO createdatatream
      else if file["type"] =="jpeg"
        #TODO createdatatream	
      end
	}
	obj.save
	#UNCOMM update = @@client.execute(%Q/update dbo.hydra_publish set hydraID=#{obj.pid} where hpid=#{i["hpid"]}/)
  end
  
  def process_children(i,ppid)
    result = @@client.execute("select bhid,oid,cid from dbo.bagHydra where dateHydraStart is null and _oid=#{i["oid"]} order by date")
    result.each { |j| 
		#UNCOMM update = @@client.execute(%Q/update dbo.hydra_publish set dateHydraStart=GETDATE() where hpid=#{j["hpid"]}/)
        process_child(i,j,ppid) 
		#UNCOMM update = @@client.execute(%Q/update dbo.hydra_publish set dateHydraEnd=GETDATE() where hpid=#{j["hpid"]}/)
    }  
  end

  def process_child(i,j,ppid)
    obj = CompoundChild.new  ##TODO create Compound child model 
	obj.label = ("oid:" << j["oid"] << " cid:" << j["cid"])
    files = @@client.execute(%Q/select type,pathHTTP,pathUNC,md5 from dbo.hydra_publish where hpid=#{j["hpid"]}/)
    files.each { |file|
	  digest = Digest::MD5.hexdigest(File.read(pathUNC))
	  if digest != md5
	    processerror(i,"failed checksum for #{pathUNC}")
		#TODO rollback functionality
	  end
      if file["type"] == "mods"
        #TODO obj.createdatastream
      else if file["type"] == "access"
        #TODO obj.createdatastream
      else if file["type"] =="rights"
        #TODO createdatatream
	  else if file["type"] == "tif"
        #TODO obj.createdatastream
      else if file["type"] =="jp2"
        #TODO createdatatream
      else if file["type"] =="jpeg"
        #TODO createdatatream	
      end
	}
	obj.add_relationship(:isMemberOf,i)
	#UNCOMM zindex = @@client.execute("Q/select top 1 _zindex from dbo.c#{j["cid"]} where oid=#{j["oid"]}/)
    #UNCOMM parent = ppid
	#DODO - create admin_metadata w/znumber and parent
	obj.save
	#UNCOMM update = @@client.execute(%Q/update dbo.hydra_publish set hydraID=#{obj.pid} where hpid=#{j["hpid"]}/)	
  end  
end  



  
