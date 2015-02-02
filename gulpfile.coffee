gulp    = require 'gulp'

coffee  = require 'gulp-coffee'
mocha   = require 'gulp-mocha'
bower   = require 'gulp-bower'
del     = require 'del'
path    = require 'path'
seq     = require 'run-sequence'
srcmaps = require 'gulp-sourcemaps'
cp      = require 'child_process'

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

gulp.task 'install', ['assets', 'bower']

gulp.task 'build', ['install'], ->
  gulp.src paths.src
    .pipe srcmaps.init()
    .pipe coffee()
    .pipe srcmaps.write()
    .pipe gulp.dest paths.dest

server = null
gulp.task 'serve', ->
  if server
    do server.kill
    server = null
  server = cp.fork 'build/server'


gulp.task 'watch', ->
  seq 'clean', 'build', 'serve', ->
    gulp.watch paths.src, ->
      seq 'clean', 'build', 'serve'

gulp.task 'default', ['watch']
