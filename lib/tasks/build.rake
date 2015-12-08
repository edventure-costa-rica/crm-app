namespace :build do
  task :bootstrap do
    Dir.chdir File.join(RAILS_ROOT, 'bower_components/bootstrap') do
      sh 'grunt dist'
    end
  end

  task :components do
    Dir.chdir File.join(RAILS_ROOT, 'public/javascripts') do
      mkdir 'pack' unless Dir.exists? 'pack'
      sh 'browserify -t reactify -r ./components/index.js:components -o pack/components.js'
    end
  end

end
