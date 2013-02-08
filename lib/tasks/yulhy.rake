#http://viget.com/extend/protip-passing-parameters-to-your-rake-tasks
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
        puts "baghydra row: #{i}"
        #TODO update = @@client.execute("%Q/update dbo.baghydra set dateHydraStart=GETDATE() where bhid=#{i["bhid"]}/) 
        if i["contentModel"] == "compound"
          #create parent object,with oid label
          files = @@client.execute(%Q/select type,path from dbo.bagHydra_paths where bhid=#{i["bhid"]}/)
          files.each { |file|
            if file["type"] == "MODS"
              #ingest MODS
            else if file["type"] == "ACCESS"
              #ingest ACCESS
            else if file["type"] =="RIGHTS"
              #ingest RIGHTS
          } 
        else if["contentModel"] == "simple
            
        end
        if i["contentModel"] =="simple"
          #
        end
      }
      #processoids()
    end
  end

  def getfiles(i)
    result = @@client.execute(%Q/select type,path from dbo.bagHydra_paths where bhid=#{i["bhid"]}/)
    if result.affected_rows == 0
      return 0
    else
      result.each { |j|
        j
      }
    end
  end
end  



  
