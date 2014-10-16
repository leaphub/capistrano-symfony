namespace :composer do

  desc 'Install a local copy of composer'
  task :install do
    on release_roles :all do |host|
      execute "cd '#{release_path}' && curl -sS https://getcomposer.org/installer | php > /dev/null"
    end
  end

  desc 'Execute a composer update'
  task :update do
    on release_roles :all do |host|
      execute "cd '#{release_path}' && php composer.phar update --prefer-dist --quiet"
    end
  end

  desc 'Dumps composer autoload'
  task :dump_autoload do
    on release_roles :all do |host|
      execute "cd '#{release_path}' && php composer.phar dump-autoload --no-dev --quiet"
    end
  end

end