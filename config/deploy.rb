# config valid only for current version of Capistrano
lock "3.7.2"

set :application, "Groupon"
set :repo_url, "git@github.com:harsh-ag/groupon.git"
set :format, :pretty
set :sudo, false
set :keep_releases, 5

set :linked_files, [ 'config/secrets.yml',
                     'config/database.yml',
                     'config/constants.yml' ]

set :linked_dirs, [ 'log',
                    'tmp/pids',
                    'tmp/cache',
                    'tmp/sockets',
                    'vendor/bundle',
                    'public/system',
                    'public/assets' ]

namespace :nginx do
  %w(stop start restart reload status).each do |action|
    desc "#{action.capitalize} Nginx"
    task action.to_sym do
      on roles([:app]) do
        execute %{echo "-----> #{action.capitalize} Nginx"}
        set :term_mode, :system
        execute "sudo service nginx #{action}"
      end
    end
  end
end

namespace :unicorn do
  task :hard_restart do
    Rake::Task[:'unicorn:stop'].invoke
    Rake::Task[:'unicorn:start'].invoke
  end

  desc 'start unicorn'
  task :start do
    on roles(:app), in: :parallel do
      within current_path do
        execute :bundle, :exec, "unicorn_rails -c config/unicorn.rb -D -E #{ fetch(:rails_env) }"
      end
    end
  end

  desc 'stop unicorn'
  task :stop do
    on roles(:app), in: :parallel do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, "kill -s QUIT 'cat #{shared_path}/tmp/pids/unicorn.pid'"
        end
      end
    end
  end

  desc 'restart unicorn'
  task :restart do
    on roles(:app), in: :parallel do
      within current_path do
        execute "kill -s USR2 'cat #{shared_path}/tmp/pids/unicorn.pid'"
      end
    end
  end
end
