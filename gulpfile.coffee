gulp    = require 'gulp'

coffee  = require 'gulp-coffee'
mocha   = require 'gulp-mocha'
del     = require 'del'

paths   =
  src : 'src/**/*.coffee'
  test: 'test/**/*.coffee'
  dest: 'build'

gulp.task 'clean', (done) ->
  del paths.dest, done

gulp.task 'build', ['clean'], ->
  gulp.src paths.src
    .pipe coffee()
    .pipe gulp.dest paths.dest

gulp.task 'watch', ->
  gulp.watch paths.src, ['build']
  gulp.watch [
    paths.test
    paths.dest
  ], ['test']

gulp.task 'test', ->
  gulp.src paths.test
    .pipe mocha
      compilers : 'coffee:coffee-script'
      reporter  : 'spec'

gulp.task 'default', ['build', 'test', 'watch']
