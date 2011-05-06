require 'rubygems'
require 'bundler/setup'

ssh_host = 'buckelew.joyent.us' 
remote_root = '/users/home/mkb/domains/orthogonal.org/web/public'

def rebuild_site(relative)
  puts ">>> Change Detected to: #{relative} >> Update Complete"
end


task :deploy do
  puts "*** Deploying the site ***"
  system("rsync -avzh --delete _site/ #{ssh_host}:#{remote_root}")
end

desc "Watch the site and regenerate when it changes"
task :watch do
  require 'fssm'
  puts ">>> Watching for Changes"
  FSSM.monitor('.', '**/*') do
    update {|base, relative| rebuild_site(relative)}
    delete {|base, relative| rebuild_site(relative)}
    create {|base, relative| rebuild_site(relative)}
  end
end

