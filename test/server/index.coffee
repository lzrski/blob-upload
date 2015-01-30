express = require 'express'
multer  = require 'multer'
fs      = require 'fs'
path    = require 'path'
coffee  = require 'coffee-script'

app = new express

app.get '/', (req, res) ->
  fs
    .createReadStream path.resolve __dirname, 'index.html'
    .pipe res.type 'text/html'

app.get '/upload.js', (req, res) ->
  fs
    .createReadStream path.resolve __dirname, '../../build/index.js'
    .pipe res.type 'text/javascript'

app.get '/test.js', (req, res) ->
  fs.readFile (path.resolve __dirname, 'test.coffee'), 'utf-8', (error, code) ->
    if error then return req.next error
    try
      res
        .type 'text/javascript'
        .send coffee.compile code
    catch error
      req.next error

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
