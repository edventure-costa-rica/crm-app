namespace :build do
  task :bootstrap do
    Dir.chdir File.join(RAILS_ROOT, 'bower_components/bootstrap') do
      sh 'grunt dist'
    end
  end

  task :components do
    Dir.chdir File.join(RAILS_ROOT, 'public/javascripts') do
      mkdir 'pack' unless Dir.exists? 'pack'
      sh 'browserify -t reactify --debug ' +
             '-r ./components/index.js:components ' +
             '-p [minifyify --map components.map.json --output pack/components.map.json] ' +
             '-o pack/components.min.js'
    end
  end

end
