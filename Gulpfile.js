var gulp = require('gulp');
var path = require('path');
var less = require('gulp-less');
var babelify = require('babelify');
var bro = require('gulp-bro');
var gutil = require('gulp-util');
var uglify = require('gulp-uglify');
var sourcemaps = require('gulp-sourcemaps');
var concat = require('gulp-concat');
var rename = require('gulp-rename');

var sources = {
  fonts: ['./node_modules/bootstrap/fonts/**/*'],
  less: ['./app/assets/less/styles.less'],
  script: ['./app/assets/javascript/application.js'],
  css: [
    './node_modules/react-date-picker/index.css',
    './node_modules/fullcalendar/dist/fullcalendar.min.css',
    './node_modules/fullcalendar/dist/fullcalendar.print.css',
  ],
  contrib: [
    './node_modules/jquery/dist/jquery.js',
    './node_modules/moment/moment.js',
    './node_modules/fullcalendar/dist/fullcalendar.js',
    './node_modules/bootstrap/dist/js/bootstrap.js',
  ]
}

var paths = {
  less: ['./app/assets/less', './node_modules/bootstrap/less'],
  script: ['./node_modules', './app/assets/javascript'],
}

gulp.task('fonts', function() {
  return gulp.src(sources.fonts)
      .pipe(gulp.dest('./public/fonts'))
})

gulp.task('less', function() {
  return gulp.src(sources.less)
    .pipe(sourcemaps.init({loadMaps: true}))
      .pipe(less({paths: paths.less}))
    .pipe(sourcemaps.write('./'))
    .pipe(gulp.dest('./public/stylesheets'))
})

gulp.task('css', function() {
  return gulp.src(sources.css)
      .pipe(rename(renameCss))
      .pipe(gulp.dest('./public/stylesheets/'));

  function renameCss(file) {
    if (file.basename === 'index') {
      file.basename = 'react-date-picker'
    }
  }
})

gulp.task('contrib', function() {
  return gulp.src(sources.contrib)
      .pipe(sourcemaps.init({loadMaps: true}))
        .pipe(uglify())
        .pipe(concat('contrib.js'))
      .pipe(sourcemaps.write('./'))
      .pipe(gulp.dest('./public/javascripts'))
})

function browserifyPipeline() {
  return gulp.src(sources.script)
      .pipe(bro({
        debug: true, 
        paths: paths.script,
        transform: [babelify.configure({presets: ['react']})],
      }));
}

gulp.task('script', function() {
  return browserifyPipeline()
      .pipe(gulp.dest('./public/javascripts/'))
});

gulp.task('release-script', function() {
  return browserifyPipeline()
      .pipe(sourcemaps.init({loadMaps: true}))
        .pipe(uglify())
        .on('error', gutil.log)
      .pipe(sourcemaps.write('./'))
      .pipe(gulp.dest('./public/javascripts/'))
})

gulp.task('watch-css', ['css'], function() {
  gulp.watch(sources.css, ['css']);
})

gulp.task('watch-less', ['less'], function() {
  gulp.watch('./app/assets/less/**/*.less', ['less'])
})

gulp.task('watch-script', ['script'], function() {
  gulp.watch('./app/assets/javascript/**/*.js', ['script'])
})

gulp.task('watch', ['watch-script', 'watch-less', 'watch-css']);
gulp.task('default', ['release-script', 'contrib', 'less', 'css']);
