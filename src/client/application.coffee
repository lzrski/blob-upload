jQuery ($) ->
  ###
  Transaction goes like this:
    1. Parent window sends message via postMessage
    2. If the message is 'get data'...
    3. ...send data back (to message.source) via postMessage
  ###

  # Data to be sent to parent window when requested
  data =
    type  : 'shop'
    name  : 'XCATS'
    stuff : 'Cool cats'
    staff :
      boss      : 'Lionel King'
      accountant: 'Marry A. Bobcat'
      sales     : [
        'Katie Cat'
        'ms. Ocelot'
        'Snow, Leopold'
      ]

  # Display data
  $('body').append $("<p>").html 'The data is:'
  $('body').append $('<pre>').html JSON.stringify data, null, 2

  window.addEventListener 'message', (message) ->
    # Always check for origin to avoid cross site scripting vulnerabilities
    # SEE: https://developer.mozilla.org/en-US/docs/Web/API/Window.postMessage#Security_concerns
    if message.origin isnt 'https://blob-upload.lazurski.pl/'
      console.error 'This PostMessage event should be ignored. For test purposes it is not.'
      # return

    if message.data is 'get data'
      # Target origin should be given instead of *
      # It's only for test purposes.
      message.source.postMessage data, '*'
