namespace :build do
  task :bootstrap do
    Dir.chdir File.join(RAILS_ROOT, 'bower_components/bootstrap') do
      sh 'grunt dist'
    end
  end

  desc 'Build JavaScript components'
  task :javascript do
    browserify = File.join(RAILS_ROOT, 'node_modules/.bin/browserify')
    scripts = %w(application.js)

    Dir.chdir File.join(RAILS_ROOT, 'public/javascripts') do
      mkdir 'pack' unless Dir.exists? 'pack'
      sh browserify + ' -t reactify --debug ' +
             '-r ./components/index.js:components ' +
             scripts.join(' ') + ' ' +
             '-p [minifyify --map application.map.json --output pack/application.map.json] ' +
             '-o pack/application.min.js'
    end
  end

end
