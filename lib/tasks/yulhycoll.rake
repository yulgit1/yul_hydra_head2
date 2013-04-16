#http://viget.com/extend/protip-passing-parameters-to-your-rake-tasks
#https://github.com/rails-sqlserver/tiny_tds
#TODO after code4lib
#https://github.com/projecthydra/active_fedora/wiki/Getting-Started:-Console-Tour
#rack security update
require '/home/ermadmix/hy_projs/yul_hydra_head2/config/environment.rb'
namespace :yulhy do
  desc "add collection from fedora"
  task :add_collection, :cid, :pid, :title do |t, args|
    args.with_defaults(:cid => "13", :pid => "25",:title=>"Hydra Test")
	cid = args[:cid]
	pid = args[:pid]
	title = args[:title]
    puts "  cid: #{cid}"
    puts "  pid: #{pid}"
    puts "  title: #{title}"
	puts ""
	puts "WARNING you are about to add a collection object to fedora/solr!  Continue?(y/n)"
	yorn = STDIN.gets.chomp
	if yorn == "y"
	  puts "You said yes, here we go."
          obj = Collection.new
          obj.label = title
          obj.cid = cid
          obj.projid = pid
          obj.title = title
	  obj.save
          puts obj.pid
	elsif yorn == "n"
	  puts "You said no, exiting."
	elsif yorn == ""
      puts "no entered nothing, exiting, please try again."	
	else
      puts %Q/You entered '#{yorn}', exiting, try again with a 'y' or 'n'/
    end	  
    #ActiveFedora::Base.find("hydrangea:fixture_mods_article1").delete
  end	  
end