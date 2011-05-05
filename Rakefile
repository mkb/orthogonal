ssh_host = 'buckelew.joyent.us' 
remote_root = '/users/home/mkb/domains/orthogonal.org/web/public'


task :deploy do
  puts "*** Deploying the site ***"
  system("rsync -avz --delete _site/ #{ssh_host}:#{remote_root}")
end