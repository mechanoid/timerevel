"use strict";
(function(){
  var gulp = require("gulp");
  var gutil = require("gulp-util");
  var through = require("through2");

  var jade = require("gulp-jade");

  var streamFunction = function(file, encoding, done) {
    this.push(file);
    return done();
  };

  var gulpPlugin = function(){
    return through.obj(streamFunction)
    .pipe(jade({pretty: true}).on('error', gutil.log))
  }

  module.exports = gulpPlugin;
}).call(this);
