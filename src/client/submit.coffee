{ expect } = chai

jQuery ($) ->
  $('#sample-form').submit (event) ->
    do event.preventDefault
    do mocha.run

    form = event.target
    data = new FormData form

    frame = $ '#appframe'
    app = frame[0].contentWindow  # The window of the application
    app.postMessage 'get data', '*'   # The application has to respond to this event

    # Wait for the application to respond with data
    window.addEventListener 'message', (message) ->
      # Security check should be:
      # return unless message.origin.match /^https:\/\/blob.lazurski.pl/i

      # Serialize data from the message
      json = JSON.stringify message.data
      blob = new Blob [json], type: 'application/json'

      # append serialized data to the form
      data.append 'attachment', blob

      # send it using jQuery.ajax
      jQuery
        .ajax
          url         : '/'
          data        : data
          type        : 'POST'
          processData : no # This...
          contentType : no # ...and this are important.
        .done (res) ->
          console.dir res
          $('#response-preview').html JSON.stringify res, null, 2

  # Test if everything went fine. This is not needed in production.
  describe 'Form submission with data from PostMessage appended', ->
    # TODO: Test each step of the transaction. Might be hard to acheive.
    it 'submit button cliked', ->
      expect true
        .to.be.ok

    it 'embeded application responded', (done) ->
      window.addEventListener 'message', (event) ->
        expect event
          .to.be.an 'object'
          .and.to.have.property 'data'
          .that.is.an 'object'
          .and.have.property 'staff'
          .that.is.an 'object'
          .and.have.property 'boss'
          .that.is.eql 'Lionel King'

        do done

    it 'data was received by the server', (done) ->
      $(document).bind 'ajaxSuccess', (event, xhr) ->
        expect xhr
          .to.be.an 'object'
          .and.have.property 'responseJSON'
          .that.is.an 'object'

        res = xhr.responseJSON
        expect res
          .to.have.property 'body'
          .that.is.an 'object'
          .and.have.property 'weight'
          .and.is.eql $('#sample-form input[name="weight"]').val()

        expect res
          .to.have.property 'decoded'
          .that.is.an 'object'
          .and.have.property 'attachment'
          .that.is.a 'string'

        json = res.decoded.attachment
        data = JSON.parse json
        expect data
          .to.be.an 'object'
          .and.have.property 'name'
          .that.is.eql 'XCATS'
        do done
