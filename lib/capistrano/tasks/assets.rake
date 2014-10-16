# Prepares the assets for a project on the local system and moves them to the deployment target.
# Currently only supports gulp as asset pipeline.
#
# The following default settings are set and can be overridden:
#   set :gulp_file, nil   A gulpfile to use in the asset creation
#   set :asset_files, []  A list of file names to copy to the deployment target after asset creation
#   set :asset_dirs, []   A list of directories to copy recursively to the deployment target after asset creation
namespace :assets do

  namespace :gulp do

    desc 'Build the assets locally using gulp'
    task :precompile do
      options = ' '
      options << "--gulpfile #{fetch(:gulp_file)}" if fetch(:gulp_file)

      run_locally do
        execute :gulp, options
      end
    end

  end

  desc 'Move precompiled assets to the deployment target'
  task :upload do
    if any? :asset_files
      on release_roles :all do |host|
        fetch(:asset_files).each do |asset_file|
          upload! asset_file, "#{release_path}/#{asset_file}"
        end
      end
    end

    if any? :asset_dirs
      on release_roles :all do |host|
        fetch(:asset_dirs).each do |asset_dir|
          execute "mkdir -p #{release_path}/#{asset_dir}"
          Dir.foreach("./#{asset_dir}") do |item|
            next if item == '.' or item == '..'
            upload! "#{asset_dir}/#{item}", "#{release_path}/#{asset_dir}/", {recursive: true}
          end
        end
      end
    end
  end

end