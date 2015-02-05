Blob upload test suit
=====================

This is a test suit showing that in most browsers it is possible to upload arbitrary data (e.g. created procedurally by a script) using multipart/form-data encoding, so that it will *look* to the server as if file was uploaded.

You can run this tests by visiting http://blob.lazurski.pl/

There is also a sample application here http://blob.lazurski.pl/host.html

There are two methods for that covered here:

  1.  Using native XMLHttpRequest API
  2.  Using `jQuery.json` method

Additionaly a method is presented to generate data in one application (running in an `iFrame`) and pass it to another (in a parent window) via [PostMessage API][].

This data is then uploaded to the server as described above.

Why
---

That way it is possible to integrate new applications with legacy code that requires larger portions of data to be encoded *as files* (or *attachments*). Until recently it required end user to *download* the file and open it using `<input type='file'>` form control. This was not user friendly at all.

Method presented here allows front-end applications to generate arbitrary data (JSON encoded objects, large portions of text, images or anything else) and to *upload* it to the legacy back-end software.

Thanks to HTML5's [FormData][] and [File][] APIs it is now possible to procedurally append file-like object (a [Blob][]) to form and send it using `XMLHttpRequest` (with `multipart/form-data` encoding). The server should treat such data as if it was uploaded using standard HTML `form`.

How is it done
--------------

There is an HTML document with a `form` and an `iFrame`.

```html
<!DOCTYPE html>
<html>
  <body>

    <form action="/" id="sample-form">
      <input type="number" name="weight" value=6>
      <input type="text" name='name' value='Scoobie'>
      <button type="submit">
    </form>

    <iframe
      src="https://example.com/application.html"
      id='appframe'
    ></iframe>

    <script src="submit.js"></script>
  </body>
</html>
```

In the `iFrame` there is an application running with different [origin][]. This application will produce some data. Before we submit the form we want to append this data to it.

This will be handled by the `submit.js` script:

```javascript
jQuery(function($) {
  // When for is to be submitted
  $('#sample-form').submit(function(event) {
    var app, data, form, frame;
    event.preventDefault();

    // get it's data
    form = event.target;
    data = new FormData(form);

    // and ask application for it's data
    frame = $('#appframe');
    app = frame[0].contentWindow;
    app.postMessage('get data', '*');

    // wait for the app to respond
    window.addEventListener('message', function(message) {
      var blob, json;

      // There should be a security check like that:
      // return unless message.origin.match /^https:\/\/blob.lazurski.pl/i

      // Serialize data from the message
      json = JSON.stringify(message.data);
      blob = new Blob([json], {
        type: 'application/json'
      });

      // and append it to form's data
      data.append('attachment', blob);

      // then send form's data to server
      return jQuery.ajax({
        url: '/',
        data: data,
        type: 'POST',
        processData: false, // this...
        contentType: false  // ...and this are important
      }).done(function(res) {
        // Everything is ready :)
      });
    });
  });
```


[PostMessage API]: https://developer.mozilla.org/en-US/docs/Web/API/Window.postMessage
[origin]: https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy
[FormData]: https://developer.mozilla.org/en-US/docs/Web/API/FormData
[File]: https://developer.mozilla.org/en-US/docs/Web/API/File
[Blob]: https://developer.mozilla.org/en-US/docs/Web/API/Blob
