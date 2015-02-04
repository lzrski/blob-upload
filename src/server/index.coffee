express = require 'express'
multer  = require 'multer'
fs      = require 'fs'
path    = require 'path'
coffee  = require 'coffee-script'
_       = require 'lodash'

app = new express

# We only process multipart/form-data encoded requests' bodies
app.use multer inMemory: yes

# Serve static files (html, scripts etc.)
app.use express.static path.resolve __dirname, '../client'

# Test scripts will send POST requests to /
app.post '/', (req, res) ->

  # Extract body (data other than files) and file info from request body
  # req.files is an object with field names as keys and files' info as values
  # See: expressjs/multer for more details
  {
    body
    files
  } = req

  # Decode each file's content as utf-8 encoded string.
  # Since multer's inMemory option was used, file.buffer holds file contents.
  # We presume it's utf-8 encoded text.
  # Note however that it can be anything that was put into a blob
  # Eg. binary data of a PNG image.
  decoded = {}
  for name, file of files
    decoded[name] = file.buffer.toString 'utf-8'

  # Respond fith processed data from req
  # so that tests can check if data wasn't corrupted.
  res.json {
    body
    files
    decoded
  }

# Error handler. Borring stuff :P
app.use (error, req, res, done) ->
  console.error error
  res
    .type   'text/plain'
    .status 500
    .send   'There was an error'
  do done

module.exports = app

if not module.parent then app.listen 8000
