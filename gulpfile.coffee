gulp    = require 'gulp'

coffee  = require 'gulp-coffee'
mocha   = require 'gulp-mocha'
bower   = require 'gulp-bower'
del     = require 'del'
path    = require 'path'
seq     = require 'run-sequence'
srcmaps = require 'gulp-sourcemaps'

paths   =
  src   : 'src/**/*.coffee'
  assets: 'src/**/*.{html,css}'
  test  : 'test/*.coffee'
  dest  : 'build/'

gulp.task 'clean', (done) ->
  del paths.dest, done

gulp.task 'bower', ->
  bower()
    .pipe gulp.dest path.resolve paths.dest, 'client'

# Copy assets as they are:
gulp.task 'assets', ->
  gulp.src paths.assets
    .pipe gulp.dest paths.dest

gulp.task 'build', ->
  seq 'clean', [
    'bower'
    'assets'
  ], ->
    gulp.src paths.src
      .pipe srcmaps.init()
      .pipe coffee()
      .pipe srcmaps.write()
      .pipe gulp.dest paths.dest

gulp.task 'watch', ['build'], ->
  gulp.watch paths.src, ['build']
  gulp.watch [
    paths.test
    path.join paths.dest, '**/*'
  ], ['test']

gulp.task 'test', ->
  gulp.src paths.test
    .pipe mocha
      compilers : 'coffee:coffee-script'
      reporter  : 'spec'

gulp.task 'default', ['watch']
