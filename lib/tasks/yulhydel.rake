#http://viget.com/extend/protip-passing-parameters-to-your-rake-tasks
#https://github.com/rails-sqlserver/tiny_tds
#TODO after code4lib
#https://github.com/projecthydra/active_fedora/wiki/Getting-Started:-Console-Tour
#1)create oid/cid/znum/parent datastream 2) create models and test
#rack security update
namespace :yulhy do
  desc "refresh hydra_publish for testing"
  task :hydra_publish_refresh do
    #client = TinyTds::Client.new(:username => 'pamojaReader',:password => 'plQ(*345',:host => 'blues.library.yale.edu',:database => 'pamoja')
    @@client = TinyTds::Client.new(:username => 'pamojaWriter',:password => 'QPl478(^%',:host => 'blues.library.yale.edu',:database => 'pamoja')
    puts "connection to db OK? #{@@client.active?}"
    if @@client.active? == false
      abort("TASK ABORTED: could not connect to db")
    end
    update = @@client.execute(%Q/update dbo.hydra_publish set dateHydraStart=null,dateHydraEnd=null,hydraId=null/)
    @@client.close
  end  
end