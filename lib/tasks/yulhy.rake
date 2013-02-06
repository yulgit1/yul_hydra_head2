#http://viget.com/extend/protip-passing-parameters-to-your-rake-tasks
namespace :yulhy do
  desc "return contents of a directory"
  task :getdir, :directory do |t,args|
    directory = args[:directory] || '/home/yulrail/data/data2'
    puts "Root Directory: #{directory}"
    recurse(directory)
  end

  def recurse(directory)
    excluded_dir = [".",".."]
    Dir.foreach(directory).each do |afile|
      fullfile = directory << "/" << afile
      file = File.new(fullfile)  
      if File.directory?(file) && !excluded_dir.include?(file)
        puts("Directory: #{file}")
        recurse(file)
      else
        if File.file?(file) && excluded_dir.include?(file)
          #puts("  File: #{File.basename(file)}")
          puts("  File: #{file}")
        end
      end
    end 
  end

end
