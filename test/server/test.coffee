# Test suit to be ran in browser
{ expect } = chai

describe 'Blob uploader', ->
  it 'is a function', ->
    expect(upload).to.be.a 'function'
        
