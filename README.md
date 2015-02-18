Funcase - IAI shop communication model
======================================

Each post message has following structure:

```javascript
{
  type  : 'string', // 'hello', 'init', 'get data' or 'data',
  body  : {} // everything else, optional
}
```
The communication goes like this (postMessages):

```
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
```

See
  * [src/client/iai-shop.coffee](src/client/iai-shop.coffee)
  * [src/client/funcase.coffee](src/client/funcase.coffee)

for compiled javascript, [see this gist](https://gist.github.com/lzrski/7bee05d43d1eb0bcd942). Comments are only in coffee-script files. Sorry.
