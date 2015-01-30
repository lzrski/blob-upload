
# Universal module definition, see: https://github.com/umdjs/umd
setup = (root, factory) ->
  # AMD
  if typeof define is 'function' and define.amd
    define [
      # Requirements go here
    ], factory

  # CommonJS (Node.js only)
  else if typeof exports is 'object'
    module.exports = factory() # Requirements go as arguments

  # Use browser globals
  else
    root.upload = factory()


setup @, ->
  return ->
