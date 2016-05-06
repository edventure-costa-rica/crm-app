var gulp = require('gulp');
var path = require('path');
var less = require('gulp-less');
var babelify = require('babelify');
var browserify = require('browserify');
var source = require('vinyl-source-stream');
var buffer = require('vinyl-buffer');
var gutil = require('gulp-util');
var uglify = require('gulp-uglify');
var sourcemaps = require('gulp-sourcemaps');
var watchify = require('watchify');

var sources = {
  fonts: ['./node_modules/bootstrap/fonts/**/*'],
  less: ['./app/assets/less/styles.less'],
  contrib: [
    './node_modules/bootstrap/dist/js/bootstrap.min.js',
    './node_modules/jquery/dist/jquery.min.js'
  ]
}

var paths = {
  less: ['./app/assets/less', './node_modules/bootstrap/less'],
  script: ['./node_modules', './app/assets/javascript'],
}

var b = createBrowserify();

gulp.task('fonts', function() {
  return gulp.src(sources.fonts)
      .pipe(gulp.dest('./public/fonts'))
})

gulp.task('less', function() {
  return gulp.src(sources.less)
    .pipe(less({paths: paths.less}))
    .pipe(gulp.dest('./public/stylesheets'))
})

gulp.task('contrib', function() {
  return gulp.src(sources.contrib)
      .pipe(gulp.dest('./public/javascripts/'));
})

gulp.task('script', function() {
  return b.bundle()
      .pipe(source('application.js'))
      .pipe(buffer())
      .pipe(sourcemaps.init({loadMaps: true}))
        .pipe(uglify())
        .on('error', gutil.log)
      .pipe(sourcemaps.write('./'))
      .pipe(gulp.dest('./public/javascripts/'))
});

gulp.task('watch-less', ['less'], function() {
  var watchedFiles = paths.less
      .map(function(p) { return path.join(p, '**/*.less') });

  gulp.watch(watchedFiles, ['less']);
})

gulp.task('watch-script', ['script'], function() {
  b.on('update', function(ids) {
    gulp.start(['script']);

  }).on('log', gutil.log)
})

gulp.task('watch-contrib', ['contrib'], function() {
  gulp.watch(sources.contrib, ['contrib']);
})

gulp.task('watch', ['watch-script', 'watch-less', 'watch-contrib']);

function createBrowserify() {
  var b = browserify({
    debug: true,
    entries: ['./app/assets/javascript/application.js'],
    paths: paths.script,
    cache: {},
    packageCache: {},

  }).transform(babelify, {presets: ['react']});

  return watchify(b);
}
