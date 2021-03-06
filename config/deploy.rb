# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'summary'
set :repo_url, 'https://github.com/karthik-mallavarapu/summary.git'
set :branch, 'master'
set :deploy_via, :remote_cache
set :stages, ["production"]

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/deploy/deployment'

# Set env to production
set :rails_env, :production
# Sym links database.yml file from shared dir
set :linked_files, %w{config/database.yml}

set :default_env, { rvm_bin_path: '~/.rvm/bin' }

role :resque_worker, "162.243.194.214"
role :resque_scheduler, "162.243.194.214"

set :workers, { "*" => 2 }

# To ensure resque can start/stop properly between deploys, you'll want to make
# sure to link the `tmp/pids` directory.
set :linked_dirs, %w(tmp/pids)

# Uncomment this line if your workers need access to the Rails environment:
set :resque_environment_task, true
# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5


namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
