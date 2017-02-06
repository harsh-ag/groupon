server '35.165.65.115', user: 'groupon', roles: [:web, :app]
set :deploy_to, '/var/www/staging'
set :rails_env, 'staging'
set :branch, 'master'
