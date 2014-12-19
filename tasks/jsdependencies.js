"use strict";
(function(){
  var gulp = require("gulp");
  var gutil = require("gulp-util");
  var through = require("through2");

  var concat = require('gulp-concat');

  var streamFunction = function(file, encoding, done) {
    this.push(file);
    return done();
  };

  var gulpPlugin = function(){
    return through.obj(streamFunction)
    .pipe(concat('dependencies.js'))
  }

  module.exports = gulpPlugin;
}).call(this);
