namespace :symfony do

  task :run, :command do |t, args|
    args.with_defaults(:command => :list)
    on roles fetch(:symfony_roles) do
      within release_path do
        execute :php, release_path.join(fetch(:symfony_console_path)), args[:command], *args.extras, "--env=#{fetch(:symfony_env)}"
      end
    end
  end

  namespace :app do

    desc "Clean app environment"
    task :clean_environment do
      on roles(:web) do |host|
        within release_path do
          execute "find #{release_path.join('web/')} -maxdepth 1 -name 'app_*.php'  | grep -v '#{fetch(:symfony_env)}' | while read app_file; do rm $app_file; done;"
        end
      end
    end
  end

  namespace :assets do

    desc 'Symfony assets deployment'
    task :install do
      # invoke is not working
      # invoke 'symfony:run', :'assets:install', fetch(:symfony_assets_flags)
      on roles fetch(:symfony_roles) do
        within release_path do
          execute :php, release_path.join(fetch(:symfony_console_path)), :'assets:install', fetch(:symfony_default_flags) + ' ' + fetch(:symfony_assets_flags), "--env=#{fetch(:symfony_env)}"
        end
      end
    end

  end

  namespace :assetic do

    desc 'Assetic dump'
    task :dump do
      on roles fetch(:symfony_roles) do
        within release_path do
          execute :php, release_path.join(fetch(:symfony_console_path)), :'assetic:dump', fetch(:symfony_default_flags) + ' ' + fetch(:symfony_assetic_flags), "--env=#{fetch(:symfony_env)}"
        end
      end
    end

  end

  namespace :parameters do

      desc 'Upload parameters.yml'
      task :upload do
          on roles fetch(:symfony_roles) do
              within shared_path do
                  if fetch(:symfony_parameters_name_scheme).nil?
                      set :symfony_parameters_name_scheme, "parameters_#{fetch(:stage)}.yml"
                  end

                  if fetch(:linked_files).nil? or not fetch(:linked_files).include?('app/config/parameters.yml')
                      raise ArgumentError.new(true), "The 'app/config/parameters.yml' file has to be defined as a :linked_files"
                  end

                  parameters_file_path = File.expand_path(
                      File.join(fetch(:symfony_parameters_path),
                                fetch(:symfony_parameters_name_scheme))
                  )

                  config_path = shared_path.join('app/config')
                  destination_file = config_path.join('parameters.yml')

                  if File.file?(parameters_file_path)
                      upload = false
                      sync = false

                      if test "[ -f #{destination_file} ]"
                          parameters_hash_local  = Digest::MD5.file(parameters_file_path).hexdigest
                          parameters_hash_remote = capture(:md5sum, destination_file).split(' ')[0]

                          sync = parameters_hash_local.to_s == parameters_hash_remote.to_s
                      end

                      if sync
                          info 'Parameters are up-to-date'
                      else
                          info 'Parameters are not sync'
                          case fetch(:symfony_parameters_upload)
                              when :always
                                  upload = true
                              when :ask
                                  $stdout.write "Parameters seems to have changed, would you like to upload #{parameters_file_path} to the remote server? [y/N] "
                                  upload = 'y' == $stdin.gets.chomp.downcase ? true : false
                              else
                                  upload = false
                          end
                      end

                      if upload
                          if test "[ ! -d #{config_path} ]"
                              execute :mkdir, '-pv', config_path
                          end

                          upload! parameters_file_path, destination_file
                      end
                  else
                      info "No parameters found #{parameters_file_path}, ignoring..."
                  end
              end
          end
      end

  end

  namespace :cache do

    desc 'Clears the cache'
    task :clear do
      # invoke is not working
      # invoke 'symfony:run', :'cache:clear', fetch(:symfony_cache_clear_flags)
      on roles fetch(:symfony_roles) do
        within release_path do
          execute :php, release_path.join(fetch(:symfony_console_path)), :'cache:clear', fetch(:symfony_default_flags) + ' ' + fetch(:symfony_cache_clear_flags), "--env=#{fetch(:symfony_env)}"
        end
      end
    end

    desc 'Warms up an empty cache'
    task :warmup do
      # invoke is not working
      # invoke 'symfony:run', :'cache:warmup', fetch(:symfony_cache_warmup_flags)
      on roles fetch(:symfony_roles) do
        within release_path do
          execute :php, release_path.join(fetch(:symfony_console_path)), :'cache:warmup', fetch(:symfony_default_flags) + ' ' + fetch(:symfony_cache_warmup_flags), "--env=#{fetch(:symfony_env)}"
        end
      end
    end

  end

  namespace :doctrine do

    desc 'Executes doctrine migrations'
    task :migrate do
      on roles fetch(:symfony_roles) do
        within release_path do
          execute :php, release_path.join(fetch(:symfony_console_path)), :'doctrine:migrations:migrate', fetch(:symfony_default_flags) + ' ' + fetch(:symfony_doctrine_migrate_flags), "--env=#{fetch(:symfony_env)}"
        end
      end
    end

    desc 'Executes doctrine schema update'
    task :schema_update do
      on roles fetch(:symfony_roles) do
        within release_path do
          execute :php, release_path.join(fetch(:symfony_console_path)), :'doctrine:schema:update', fetch(:symfony_default_flags) + ' ' + fetch(:symfony_doctrine_schema_update_flags), "--env=#{fetch(:symfony_env)}"
        end
      end
    end

    desc 'Load doctrine fixtures'
    task :fixtures_load do
      on roles fetch(:symfony_roles) do
        within release_path do
          execute :php, release_path.join(fetch(:symfony_console_path)), :'doctrine:fixtures:load', fetch(:symfony_default_flags) + ' ' + fetch(:symfony_doctrine_fixture_flags), "--env=#{fetch(:symfony_env)}"
        end
      end
    end

  end

  after 'deploy:updated', 'symfony:parameters:upload'
  before 'deploy:publishing', 'symfony:cache:warmup'
  before 'deploy:publishing', 'symfony:app:clean_environment'
  # this hook work using invoke
  # after 'deploy:updated', 'symfony:cache:warmup'

end

namespace :load do

  task :defaults do
    set :symfony_console_path, 'app/console'
    set :symfony_roles, :web
    set :symfony_default_flags, '--quiet --no-interaction'
    set :symfony_assets_flags, '--symlink'
    set :symfony_assetic_flags, ''
    set :symfony_cache_clear_flags, ''
    set :symfony_cache_warmup_flags, ''
    set :symfony_doctrine_migrate_flags, ''
    set :symfony_doctrine_schema_update_flags, '--force'
    set :symfony_doctrine_fixture_flags, ''
    set :symfony_env, 'prod'
    set :symfony_parameters_upload, :ask
    set :symfony_parameters_path, 'app/config/'
  end

end
