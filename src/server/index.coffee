express = require 'express'
multer  = require 'multer'
fs      = require 'fs'
path    = require 'path'
coffee  = require 'coffee-script'
_       = require 'lodash'

app = new express

app.use multer inMemory: yes

app.use express.static path.resolve __dirname, '../client'

app.post '/', (req, res) ->
  {
    body
    files
  } = req

  decoded = {}
  for name, file of files
    decoded[name] = file.buffer.toString 'utf-8'

  res.json {
    body
    files
    decoded
  }

# Error handler
app.use (error, req, res, done) ->
  console.error error
  res
    .type   'text/plain'
    .status 500
    .send   'There was an error'
  do done

module.exports = app

if not module.parent then app.listen 8000
