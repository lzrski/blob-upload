###
Each post message has following structure:
  type  : 'hello' or 'init' or 'get data' or 'data'
  body  : { *everything else, optional* }

The communication goes like this (postMessages):

IAI Shop                Funcase
--------                -------
                        *iframe loaded*
    |<------ hello -------
    |------- init ------->
                        *funcase is initializing*
                        *user plays with it*

*form.submit*
    ----- get data ------>|
                        *data is gathered*
    <------- data --------|
*item is added to cart
along with data attachement*
###


jQuery ($) ->
  funcase = document
    .getElementById 'appframe'  # The iFrame of the funcase application
    .contentWindow              # The window of the funcase application


  window.addEventListener 'message', (message) ->
    if message.origin isnt 'http://funcase.lazurski.pl'
      console.error 'This PostMessage event should be ignored. For test purposes it is not.'
      # return

    { type, body } = message.data
    switch type
      # First, we wait for hello message from the funcase application
      # It indicates that it is ready to be initialized
      when 'hello'
        # Let's initialize the embeded funcase application
        message.source.postMessage
          type    : 'init'
          body    :
            # Inform funcase application about the host platform
            platform: 'IAI Shop'

            # Set API version - let's be future proof
            api     : '1.0'

            # The overlay image url. This will be different for each product.
            # TODO: We will run into problems with [CORS](https://developer.mozilla.org/en-US/docs/Web/HTML/CORS_enabled_image).
            overlay : '/cats.jpg'
          , '*'

  # When the user submits the form
  $('#sample-form').submit (event) ->
    do event.preventDefault

    form = event.target
    data = new FormData form

    # Get the attachment from the funcase application
    funcase.postMessage type  : 'get data', '*'

    # Wait for the funcase application to respond with data
    window.addEventListener 'message', (message) ->
      # Security check:
      unless message.origin is 'http://funcase.lazurski.pl'
        console.error 'This PostMessage event should be ignored. For test purposes it is not.'
        # return

      # Serialize data from the message
      json = JSON.stringify message.data
      blob = new Blob [json], type: 'application/json'

      # append serialized data to the form
      data.append 'attachment', blob

      # send it using jQuery.ajax
      jQuery
        .ajax
          url         : form.action
          data        : data
          type        : 'POST'
          processData : no # This...
          contentType : no # ...and this are important.
        .done (res) ->
          console.dir res
          $('#response-preview').html JSON.stringify res, null, 2
