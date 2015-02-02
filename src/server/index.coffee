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
  res.json _.pick req, ['body', 'files']

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
