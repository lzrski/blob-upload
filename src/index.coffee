# Universal module definition, see: https://github.com/umdjs/umd

setup = (root, factory) ->
  # AMD
  if typeof define is 'function' and define.amd
    define [
      'lodash'
    ], factory

  # CommonJS (Node.js only)
  else if typeof exports is 'object'
    module.exports = factory(require 'lodash')

  # Use browser globals
  else
    root.upload = factory(_)


setup @, (_) ->

  # The actual code goes below.
  return (urldata, done) ->
    form = new FormData
    for key, value of data
      if _.isArray value then for element in value
        form.append key, element
      else
        form.append key, value

    req = new XMLHttpRequest
    req.responseType = 'json'
    req.open 'post', 'http://localhost:8000'
    req.send form
