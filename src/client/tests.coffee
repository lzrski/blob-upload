# Test suit to be ran in browser
{ expect } = chai

describe 'XHR FormData API', ->

  it 'can send simple object', (done) ->
    data =
      name: 'Katiusza'
      age : '4' # Everything is converted to string by multipart form data enc.

    form = new FormData
    for key, value of data
      form.append key, value

    req = new XMLHttpRequest

    # Response type must be set after request is opened.
    # Otherwise IE will spit in your eye.
    # See: https://connect.microsoft.com/IE/feedback/details/795580
    req.open 'post', '/'
    req.responseType = 'json'
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
    req.open 'post', '/'
    req.responseType = 'json'
    req.send form
    req.onload = ->
      expect(@status).to.eql 200
      expect(@responseType).to.eql 'json'
      expect(@response.body).to.eql data
      do done

  it 'can send blobs as files', (done) ->
    data =
      name: 'Katiusza'
      age : '4'
      toys: [
        'sznurek'
        'jajo'
        'korek'
      ]
      anathem : new Blob [
        'Bardzo mała jest nasza Katiucha'
        'Mierzona od ucha do ucha.'
        'Natomiast gdy jest mierzona'
        'Od ucha do ogona'
        'To nadal jest nieduża.'
        'Ot, cała nasza katiusza!'
      ], type: 'text/plain', fileName: 'anathem.txt'

    form = new FormData
    for key, value of data
      if _.isArray value then for element in value
        form.append key, element
      else
        form.append key, value

    req = new XMLHttpRequest
    req.open 'post', '/'
    req.responseType = 'json'
    req.send form
    req.onload = ->
      expect(@status).to.eql 200
      expect(@responseType).to.eql 'json'
      expect(@response.body).to.eql _.omit data, ['anathem']
      expect(@response.files).to
        .be.an 'object'
        .and.have.property 'anathem'

      expect(@response.files.anathem).to
        .be.an 'object'
        .and.have.property 'size', data.anathem.size
        
      do done
