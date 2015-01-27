should = require 'should'

upload = require '../'

describe 'Blob upload', ->
  it 'is a function', ->
    upload.should.be.type 'function'
