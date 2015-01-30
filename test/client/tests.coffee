# Test suit to be ran in browser
{ expect } = chai

describe 'XHR FormData API', ->
  it 'works', ->
    expect(a: 'co').to.eql a: 'co'

  it 'can send simple object', (done) ->
    data =
      name: 'Katiusza'
      age : '4' # Everything is converted to string by multipart form data enc.

    form = new FormData
    for key, value of data
      form.append key, value

    req = new XMLHttpRequest
    req.responseType = 'json'
    req.open 'post', 'http://localhost:8000'
    req.send form
    req.onload = ->
      expect(@status).to.eql 200
      expect(@responseType).to.eql 'json'
      expect(@response.body).to.eql data
      do done

  it 'can send object with nested array', (done) ->
    data =
      name: 'Katiusza'
      age : '4'
      toys: [
        'sznurek'
        'jajo'
        'korek'
      ]

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
    req.onload = ->
      expect(@status).to.eql 200
      expect(@responseType).to.eql 'json'
      expect(@response.body).to.eql data
      do done
