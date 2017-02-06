server '52.24.1.116', user: 'groupon', roles: [:web, :app]
set :deploy_to, '/var/www/staging'
set :rails_env, 'staging'
set :branch, 'master'
