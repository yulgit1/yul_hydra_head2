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
    result = @@client.execute("select top 1 bhid,oid,cid,contentModel from dbo.bagHydra where dateHydraStart is null and _oid=0 order by date")
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
	#UNCOMM update = @@client.execute(%Q/update dbo.baghydra set dateHydraStart=GETDATE() where bhid=#{i["bhid"]}/)
	if i["contentModel"] == "compound"
	  process_compound(i)
	else if i["contentModel"] =="simple"
      process_simple(i)
    else 
      processerror(i,"content model: #{i["contentModel"]} not instantiated")	
	end
	#UNCOMM update = @@client.execute(%Q/update dbo.baghydra set dateHydraEnd=GETDATE() where bhid=#{i["bhid"]}/)
  end

  def processerror(i,errormsg)
    puts "error for oid: #{i["oid"]} errormsg: #{errormsg}"
    #UNCOMM ehid = @@client.execute(%Q/insert into dbo.errorhydra (oid,errormsg,errortime) values (#{i["oid"]},#{errormsg},GETDATE()) select @@identity/);
	#UNCOMM @@client.execute(%Q/insert into dbo.baghydra_errorhydra (bhid,ehid) values (#{i["bhid"]},#{i["ehid"]})
  end

  def process_compound(i)          
    obj = CompoundParent.new  ##TODO create CompoundParent model 
	obj.label = ("oid:" << i["oid"]  << " cid:" << i["cid"])
    files = @@client.execute(%Q/select type,path from dbo.bagHydra_paths where bhid=#{i["bhid"]}/)
    files.each { |file|
	  if file["type"] == "mods"
        #TODO obj.createdatastream
      else if file["type"] == "access"
        #TODO obj.createdatastream
      else if file["type"] =="rights"
        #TODO createdatatream
      end
	}
	obj.save
	#UNCOMM update = @@client.execute(%Q/update dbo.baghydra set hydraid=#{obj.pid} where bhid=#{i["bhid"]}/)
    process_children(i)
  end
  
  def process_simple(i)
    obj = Simple.new  ##TODO create Simple model 
	obj.label = ("oid:" << i["oid"] << " cid:" << i["cid"])
    files = @@client.execute(%Q/select type,path from dbo.bagHydra_paths where bhid=#{i["bhid"]}/)
    files.each { |file|
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
	#UNCOMM update = @@client.execute(%Q/update dbo.baghydra set hydraid=#{obj.pid} where bhid=#{i["bhid"]}/)
  end
  
  def process_children(i)
    result = @@client.execute("select bhid,oid,cid from dbo.bagHydra where dateHydraStart is null and _oid=#{i["oid"]} order by date")
    result.each { |j| 
		#UNCOMM update = @@client.execute(%Q/update dbo.baghydra set dateHydraStart=GETDATE() where bhid=#{j["bhid"]}/)
        process_child(i,j) 
		#UNCOMM update = @@client.execute(%Q/update dbo.baghydra set dateHydraEnd=GETDATE() where bhid=#{j["bhid"]}/)
    }  
  end

  def process_child(i,j)
    obj = CompoundChild.new  ##TODO create Compound child model 
	obj.label = ("oid:" << j["oid"] << " cid:" << j["cid"])
    files = @@client.execute(%Q/select type,path from dbo.bagHydra_paths where bhid=#{j["bhid"]}/)
    files.each { |file|
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
	#DOTO - znumber and parent
	obj.save
	#UNCOMM update = @@client.execute(%Q/update dbo.baghydra set hydraid=#{obj.pid} where bhid=#{j["bhid"]}/)	
  end  
end  



  
