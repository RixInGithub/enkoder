# enkoder
this package has no dependencies!

start by installing w/ luarocks:
```sh
luarocks install enkoder
```

next, use enkoder however you'd like!

## usage
to get started with enkoder, simply `require("enkoder")` to get a callable with items as follows:
### `enkoder.null`
a simple dropin null value that enkoder uses.

this is a callable that returns `enkoder.null`. if stringified, returns `"enkoder.null"`.

TODO: support `dkjson` null too
### `enkoder(inp, opts)`
inp can either be a table to encode, or a string to decode.

opts can either be a string for one single format to encode to/decode from, or a list-ish table of strings to denote multiple formats, or a key/value table of keys being format id strings and value being a table for specific format options.

note that in the examples below, any values that are `nil` in a key/value table are not captured because of lua's internal workings, however (sparse) list-ish tables can have regular lua `nil` in them

here are the following formats and their options:
#### `json`
the classic, the javascript object notation format. no options here.

example:

```
> require("enkoder")({groceries = "yummh!", greenland = nil, greenland2 = require("enkoder").null, greenlands = {[1] = "im green...", [6] = "...dah buh dee dah buh die!!"}, swagLevels = 1000, more = {one = "jeffinitely"}, evenMore = {"hell yeah"}, h = {"yep", h = "h", "wut"}}, "json")
{"groceries":"\u0079\u0075\u006d\u006d\u0068\u0021","swagLevels":1000,"greenland2":[],"more":{"one":"\u006a\u0065\u0066\u0066\u0069\u006e\u0069\u0074\u0065\u006c\u0079"},"evenMore":["\u0068\u0065\u006c\u006c\u0020\u0079\u0065\u0061\u0068"],"greenlands":["\u0069\u006d\u0020\u0067\u0072\u0065\u0065\u006e\u002e\u002e\u002e",null,null,null,null,"\u002e\u002e\u002e\u0064\u0061\u0068\u0020\u0062\u0075\u0068\u0020\u0064\u0065\u0065\u0020\u0064\u0061\u0068\u0020\u0062\u0075\u0068\u0020\u0064\u0069\u0065\u0021\u0021"],"h":{"1":"\u0079\u0065\u0070","2":"\u0077\u0075\u0074","h":"\u0068"}}
```
#### `yaml`
yaml, aka "yaml ain't markup language". `yml` is an available alias for yaml.

the only options this format optionally can gulp down is `indent`. the `indent` can be any number, minimum value 2 but the default is 4.

example:

```
> require("enkoder")({groceries = "yummh!", greenland = nil, greenland2 = require("enkoder").null, greenlands = {[1] = "im green...", [6] = "...dah buh dee dah buh die!!"}, swagLevels = 1000, more = {one = "jeffinitely"}, evenMore = {"hell yeah"}, h = {"yep", h = "h", "wut"}}, {yaml={indent=4}})
groceries: |
    yummh!
swagLevels: 1000
greenland2:
more:
    one: |
        jeffinitely
evenMore:
    - |
        hell yeah
greenlands:
    - |
        im green...
    - null
    - null
    - null
    - null
    - |
        ...dah buh dee dah buh die!!
h:
    1: |
        yep
    2: |
        wut
    h: |
        h
```