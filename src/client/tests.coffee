# Test suit to be ran in browser
{ expect } = chai

describe 'This browser', ->
  it 'supports Blob', ->
    blob = new Blob ['Czy Blob to ładne imię dla kota?']
    expect blob
      .to.be.an 'object'
      .and.have.property 'size'

  it "let's blob have type", ->
    blob = new Blob ['Raczej dla psa!'], type: 'text/plain'
    expect blob
      .to.be.an 'object'
      .and.have.property 'size'

  it 'supports FormData API', ->
    data = new FormData
    expect data
      .to.be.an 'object'
      .and.have.property 'append'
      .that.is.a 'function'

    data.append 'what', 'a Cat'
    data.append 'where', 'in a box'

    expect data
      .to.be.an 'object'

  it "can create a FormData from an HTML form", ->
    form = document.getElementById 'sample-form'
    data = new FormData form

    expect data
      .to.be.an 'object'
      .and.to.have.property 'append'
      .that.is.a 'function'

  it "allows a Blob to be appended to FormData instance", ->
    blob = new Blob [
      'Jak się Pani podoba mój krokodyl?'
      'Bardzo ładnie chodzi na smyczy!'
      'Prawda :)'
    ], type: 'text/plain'
    expect blob
      .to.be.an 'object'
      .and.have.property 'size'

    data = new FormData
    data.append 'dialog', blob

  it "can append a Blob to a FormData created from an HTML form", ->
    form = document.getElementById 'sample-form'
    data = new FormData form

    expect data
      .to.be.an 'object'
      .and.to.have.property 'append'
      .that.is.a 'function'

    blob = new Blob [
      'A czy ten krokodyl jast grzeczny?'
      'Droga Pani - najzupełniej! Gryzie tylko listonosza i sznur od żelazka.'
      'To rozkosznie! Jak się nazywa?'
      'Blob!'
    ], type: 'text/plain'
    expect blob
      .to.be.an 'object'
      .and.have.property 'size'

    data.append 'dialog', blob

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

      # IE11 and Safari 7 doesn't support xhr.responseType = 'json'.
      # See: http://stackoverflow.com/a/9845704/1151982
      # Let's make sure that we work on an object, not a string.
      # Note that xhr.response is read-only in IE
      # See: https://msdn.microsoft.com/en-us/library/ie/hh872881(v=vs.85).aspx
      {response} = @
      if typeof response is 'string' then response = JSON.parse response

      expect response
        .to.be.an 'object'
        .and.have.property 'body'
        .that.eql data

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

      # IE11 and Safari 7 doesn't support xhr.responseType = 'json'.
      # Let's convert it if necessary.
      {response} = @
      if typeof response is 'string' then response = JSON.parse response

      expect response
        .to.be.an 'object'
        .and.have.property 'body'
        .that.eql data

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
      anthem : new Blob [
        'Bardzo mała jest nasza Katiucha'
        'Mierzona od ucha do ucha.'
        'Natomiast gdy jest mierzona'
        'Od ucha do ogona'
        'To nadal jest nieduża.'
        'Ot, cała nasza katiusza!'
      ], type: 'text/plain'

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

      # IE11 and Safari 7 doesn't support xhr.responseType = 'json'.
      # Let's convert it if necessary.
      {response} = @
      if typeof response is 'string' then response = JSON.parse response

      expect response
        .to.be.an 'object'
        .and.have.property 'body'
        .that.eql _.omit data, ['anthem']

      expect response
        .be.an 'object'
        .and.have.property 'files'
        .that.is.an 'object'
        .and.have.property 'anthem'
        .that.is.an 'object'
        .and.have.property 'size'
        .that.eql data.anthem.size

      do done

describe 'jQuery + FormData', ->
  # See: https://developer.mozilla.org/en-US/docs/Web/Guide/Using_FormData_Objects
  it 'can send simple FormData object', (done) ->
    data =
      name: 'Katiusza'
      age : '4' # Everything is converted to string by multipart form data enc.

    form = new FormData
    for key, value of data
      form.append key, value

    jQuery
      .ajax
        url         : '/'
        data        : form
        type        : 'POST'
        processData : no
        contentType : no
      .done (res) ->
        expect(res).to
          .be.an 'object'
          .and.have.property 'body'
          .that.is.an 'object'
          .and.have.keys [
            'name'
            'age'
          ]

        do done

  it 'can send blobs as files', (done) ->
    # Cool cats here: https://user.xmission.com/~emailbox/ascii_cats.htm
    ascii = """
      |               __..--''``---....___   _..._    __
      |     /// //_.-'    .-/";  `        ``<._  ``.''_ `. / // /
      |    ///_.-' _..--.'_    \                    `( ) ) // //
      |    / (_..-' // (< _     ;_..__               ; `' / ///
      |     / // // //  `-._,_)' // / ``--...____..-' /// / //
      | Felix Lee
    """

    # Preserve delimeters while splitting string. Neat :)
    # See: http://stackoverflow.com/a/12001989/1151982
    lines = ascii.split /(?=\n)/

    blob  = new Blob lines, type: 'text/plain'

    data =
      name: 'George'
      age : '4'
      toys: [
        'sznurek'
        'kocyk'
        'pudło'
      ]
      image: blob

    form = new FormData
    for key, value of data
      if _.isArray value then for element in value
        form.append key, element
      else
        form.append key, value

    jQuery
      .ajax
        url         : '/'
        data        : form
        type        : 'POST'
        processData : no
        contentType : no
      .done (res) ->
        expect res
          .to.be.an 'object'
          .and.have.property 'body'
          .that.is.an 'object'
          .and.have.keys [
            'name'
            'age'
            'toys'
          ]

        expect res
          .to.be.an 'object'
          .and.have.property 'files'
          .that.is.an 'object'
          .and.have.property 'image'
          .that.is.an 'object'
          .and.have.property 'size'
          .that.eql data.image.size

        expect res
          .to.be.an 'object'
          .and.have.property 'decoded'
          .that.is.an 'object'
          .and.have.property 'image'
          .that.is.an 'string'
          .that.is.eql ascii

        do done

  it 'can use data from html form', (done) ->
    form = new FormData $('form')[0]

    # More cool cats here: http://www.asciiworld.com/-Cats-.html
    ascii = """
      |                      ,/\,,,,/\,.
      |                     =          =,
      |                    =` '<Q> <Q>'  =,
      |         ,=~~~~~~~~~`=     Y    =,`;,
      |       ,='            // :-^-; \\  `;
      |     ,='       `      ,,,,.'       :;
      |     ;,        '`          ':      `;
      |     ;`         ;',          ::,   ;;
      |     '\`   `,`';'`'`;`'`;';,  `; ':;
      |      '\`  '`\;~~~;/~~;~;/\`,  ';'`;
      |      /#\`  `'\#############)),';~#\
      |     /##\`  '`\\############))_;####\
      |    |###\`'`'\\MMMMMMMMMMMMMMMMMMMMMM|
      |    |NNNN\`'`\\NNNNNNNNNNNNNNNNNNNNNN|
      |    |YYYYY`\\\`YYYYYYYYYYYYYYYYYYYYYY|
      |    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      |    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      |    ::::::::::::::::::::::::::::::::::
      |----''''''''''''''''''''''''''''''''''----
    """
    lines = ascii.split /(?=\n)/
    blob  = new Blob lines, type: 'text/plain'

    form.append 'image', blob

    jQuery
      .ajax
        url         : '/'
        data        : form
        type        : 'POST'
        processData : no
        contentType : no
      .done (res) ->

        expect res
          .to.be.an 'object'
          .and.have.property 'body'
          .that.is.an 'object'
          .and.have.keys [
            'name'
            'weight'
          ]

        expect res
          .to.be.an 'object'
          .and.have.property 'files'
          .that.is.an 'object'
          .and.have.property 'image'
          .that.is.an 'object'
          .and.have.property 'size'
          .that.eql blob.size

        expect res
          .to.be.an 'object'
          .and.have.property 'decoded'
          .that.is.an 'object'
          .and.have.property 'image'
          .that.is.an 'string'
          .that.is.eql ascii

        do done

  it 'can upload arbitrary data encoded as JSON', (done) ->
    # Given any object
    data =
      name  : 'Pimpek'
      toys  : [
        'kłębęk'
        'mysza'
      ]

    # Serialize it as JSON string
    json = JSON.stringify data

    # And make a blob with it's contents
    blob = new Blob [ json ], type: 'application/json'

    # Create FormData object and append the blob to it
    form = new FormData
    form.append 'data', blob

    # Send it using jQuery.ajax
    jQuery
      .ajax
        url         : '/'
        data        : form
        type        : 'POST'
        processData : no # This...
        contentType : no # ...and this is important.
      .done (res) ->
        # The server receive it as a if it was a file
        # Here we have sample response from our test server.
        # See /src/server/index.coffee for more information.
        expect(res).to
          .be.an 'object'
          .and.have.property 'files'
          .that.is.an 'object'
          .and.have.property 'data'
          .that.is.an 'object'
          .and.have.property 'size'
          .that.is.eql blob.size

        # Our server also decodes each file and responds with it's text content.
        # Again see /src/server/index.coffee for better insight.
        expect(res).to
          .be.an 'object'
          .and.have.property 'decoded'
          .that.is.an 'object'
          .and.have.property 'data'
          .that.is.a 'string'
          .and.is.eql json

        # The object stored in a file is intact.
        # We can parse it as JSON and get our data back!
        parsed = JSON.parse res.decoded.data
        expect parsed
          .to.be.an 'object'
          .and.to.be.eql data

        # Simple!
        do done

describe 'PostMessage API', ->
  it 'can request and receive a data from another application', (done) ->
    # An iframe in parent document
    frame = document.getElementById 'appframe'
    app   = frame.contentWindow

    # Request data from embeded application
    # See src/client/application.coffee for more details
    # Target origin should be given instead of *
    # It's only for test purposes.
    app.postMessage 'get data', '*'

    # Wait for response
    window.addEventListener 'message', (event) ->

      # Always check for origin to avoid cross site scripting vulnerabilities
      if event.origin isnt 'https://blob-upload.lazurski.pl/application.html'
        console.error 'This PostMessage event should be ignored. For test purposes it is not.'
        # return

      # Data sent via PostMessage should be assigned to event.data
      expect event.data
        .to.be.an 'object'
        .and.have.property 'staff'
        .that.is.an 'object'
        .and.have.property 'sales'
        .that.is.an 'array'
        .and.is.eql [
          'Katie Cat'
          'ms. Ocelot'
          'Snow, Leopold'
        ]

      do done
