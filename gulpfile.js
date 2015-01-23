"use strict";

// Gulp Stack
var gulp = require('gulp');
var gutil = require('gulp-util');
var print = require('gulp-print');
var livereload = require('gulp-livereload');
var watch = require('gulp-watch');
var deploy = require('gulp-gh-pages');
var copy = require('gulp-copy');
var concat = require('gulp-concat');
var googlecdn = require('gulp-google-cdn');

// Server Setup
var http = require('http');
var ecstatic = require('ecstatic');

// remove plugin for clean task
var rimraf = require('rimraf');

// building frontend files
// var csspreprocessing = require('./tasks/csspreprocessing');
var htmlpreprocessing = require('./tasks/htmlpreprocessing');
var jspreprocessing = require('./tasks/jspreprocessing');
var jsdependencies = require('./tasks/jsdependencies');

// list of js dependencies, not available via cdn, that we want to concatenate to a dependency js file,
// so that only a single http request is necessary for them.
var vendorDependencies = [
  // './bower_components/onScreen/jquery.onscreen.js'
];


gulp.task('stylus', function(){
  // gulp.src('stylus/*.styl').pipe(csspreprocessing()).pipe(gulp.dest('css'));
});


gulp.task('coffee', ['views'], function () {
  gulp.src(['./coffeescript/libs/**/*.coffee', './coffeescript/app.coffee'])
  .pipe(jspreprocessing())
  .pipe(concat('app.js'))
  .pipe(gulp.dest('./javascripts/'));
});


gulp.task('vendor-dependencies', function () {
  gulp.src(vendorDependencies)
  .pipe(jsdependencies())
  .pipe(gulp.dest('./javascripts/'));
});


gulp.task('templates', function() {
  gulp.src(['./templates/*.jade', './views/**/*.jade'])
  .pipe(htmlpreprocessing())
  .pipe(gulp.dest('./'));
});


gulp.task('views', function() {
  gulp.src(['./views/**/*.jade'])
  .pipe(htmlpreprocessing())
  .pipe(gulp.dest('./views/'));
});


gulp.task('clean', function (done) {
  rimraf('./build', done);
})


gulp.task('build', ['templates', 'stylus', 'coffee', 'vendor-dependencies']);


gulp.task('cleanbuild', ['clean', 'build']);


gulp.task('package', ['cleanbuild'], function (done) {
    var stream = gulp.src(['./*.html', './css/**/*', './javascripts/**/*', './fonts/**/*', './images/**/*']).pipe(copy('build'));
    stream.on('end', function(){
      done();
    });
    stream.on('err', function(err){
      done(err);
    });
});


gulp.task('bower-2-google-cdn', ['package'], function () {
    return gulp.src(['build/**/*.html'])
        .pipe(googlecdn(require('./bower.json'), {cdn: "cdnjs" ,debug: true}))
        .pipe(gulp.dest('build'));
});


gulp.task('deploy', ['bower-2-google-cdn'], function () {
    return gulp.src('build/**/*')
    .pipe(deploy({cacheDir: './tmp'}));
});


gulp.task('watch', function() {
  livereload.listen();

  gulp.watch(__dirname + '/**/*.styl', ['stylus']).on('change', livereload.changed);
  gulp.watch(__dirname + '/**/*.coffee', ['coffee']).on('change', livereload.changed);
  gulp.watch(__dirname + '/templates/**/*.jade', ['templates']).on('change', livereload.changed);
  gulp.watch(__dirname + '/views/**/*.jade', ['views']).on('change', livereload.changed);
});

gulp.task('createServer', function() {
  var port = 4567;

  http.createServer(
  ecstatic({
    root: __dirname
    , cache: 0
  })
  ).listen(port);

  gutil.log('Ecstatic server listening on: ' + port);
});


gulp.task('server', ['cleanbuild', 'watch', 'createServer']);
