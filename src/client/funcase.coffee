# This is a sample application for API test purposes only.
# It will do real things later.

# Sample data to be sent when requested
# Additional property (preview) will be added to it in 'get data' part below
data =
  fabric:
    # This is not a real data - only a sample
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

# When everything is ready...
jQuery ($) ->
  # Check if the application is running inside a frame
  if window.top is window then return $('body').html """
    <h1>This application is supposed to be running in a frame</h1>
  """

  host  = window.top # Host application window

  # Say 'hello' to indicate that the application is ready.
  # Host application should wait for 'hello' before sending 'init' message
  host.postMessage type  : 'hello', '*'

  # Now we wait for the host to send messages.
  window.addEventListener 'message', (message) ->

    # Make sure the origin is correct
    if message.origin isnt 'https://xgsm.pl'
      console.error 'This PostMessage event should be ignored. For test purposes it is not.'
      # return

    # Each message has a
    #   * type - String; 'init', 'get data' or 'load data')
    #   * body - optional, type specific data
    { type, body } = message.data

    switch type
      when 'init'
        # Initialize the app
        # It expects to receive info regarding:
        #   * host platform
        #   * API version
        #   * Overlay image PNG (different for each product)

        # This is for test purposes only
        # Here we try to load image into canva to serialize it later
        # in response to 'get data' message.
        canvas  = document.createElement 'canvas'
        image   = document.createElement 'img'
        $(image).one 'load', ->
          canvas.id     = 'overlay'
          canvas.height = image.height
          canvas.width  = image.width
          canvas
            .getContext '2d'
            .drawImage image, 0, 0

          document.body.appendChild canvas

        image.src = body.overlay
        # Make sure the load is triggered for cached images
        # SEE: http://stackoverflow.com/questions/7844982/
        if image.complete or image.width then do $(image).load

        # After that the user can play with application

      when 'get data'
        # Host wants to get the data

        # Prepare fake large base64 data by serializing a canvas
        canvas = document.getElementById 'overlay'
        data.preview = canvas.toDataURL 'image/png'

        # Send the data
        message.source.postMessage
          type  : 'data'
          body  : data
          , '*'
