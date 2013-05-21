require '/home/ermadmix/hy_projs/yul_hydra_head2/config/environment.rb'
namespace :yulhy do
  desc "test using yml"
  task :test_yaml do
    lbconf = YAML.load_file ('config/ladybird.yml')
    puts lbconf.fetch("username").strip
    puts lbconf.fetch("password").strip
    puts lbconf.fetch("host").strip
    puts lbconf.fetch("database").strip
  end
end