namespace :build do
  task :bootstrap => :environment do
    Dir.chdir File.join(RAILS_ROOT, 'bower_components/bootstrap') do
      sh 'grunt dist'
    end
  end

end
