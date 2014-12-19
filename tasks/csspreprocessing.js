"use strict";
(function(){
  var gulp = require("gulp");
  var gutil = require("gulp-util");
  var through = require("through2");

  var stylus = require('gulp-stylus');
  var nib = require('nib');
  var jeet = require('jeet');
  var rupture = require('rupture');

  var streamFunction = function(file, encoding, done) {
    this.push(file);
    return done();
  };

  var gulpPlugin = function(){
    return through.obj(streamFunction).pipe(stylus({use: [nib(), jeet(), rupture()]}));
  }

  module.exports = gulpPlugin;
}).call(this);
