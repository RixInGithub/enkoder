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
a simple dropin null value that enkoder uses. completely compatible with `dkjson.null`!

this is a callable that returns `enkoder.null`. if stringified, returns `"enkoder.null"`.

`enkoder.null` also has the `__eq(a, b)` metamethod to check if a and b are reported true by `enkoder.isNull`.

it can also be encoded into json `null` by `dkjson.encode`!
### `enkoder.isNull(a)`
a is the object to test if null using some clever tactics. will check if a is `enkoder.null` or `dkjson.null`
### `enkoder(inp, opts)`
inp can be a string to decode, or anything else to encode.

opts can either be a string for one single format to encode to/decode from, or a list-ish table of strings to denote multiple formats, or a key/value table of keys being format id strings and value being a table for specific format options.

note that in the examples below, any values that are `nil` in a key/value table are not captured because of lua's internal workings, however (sparse) list-ish tables can have regular lua `nil` in them

here are the following formats and their options:
#### `json`
the classic, the javascript object notation format. no options here.

example:

```
> require("enkoder")({groceries = "yummh!", greenland = nil, greenland2 = require("enkoder").null, greenlands = {[1] = "im green...", [6] = "...dah buh dee dah buh die!!"}, swagLevels = 1000, more = {one = "jeffinitely"}, evenMore = {"hell yeah"}, h = {"yep", h = "h", "wut"}}, "json")
{"groceries":"yummh!","more":{"one":"jeffinitely"},"swagLevels":1000,"greenlands":["im green...",null,null,null,null,"...dah buh dee dah buh die!!"],"greenland2":null,"evenMore":["hell yeah"],"h":{"1":"yep","2":"wut","h":"h"}}
```
#### `yaml`
yaml, aka "yaml ain't markup language". `yml` is an available alias for yaml.

the only options this format optionally can gulp down is `indent`. the `indent` can be any number, minimum value 1 but the default is 4.

doesn't support encoding non-tables and decoding yet.

example:

```
> print(require("enkoder")({groceries = "yummh!", greenland = nil, greenland2 = require("enkoder").null, greenlands = {[1] = "im green...", [6] = "...dah buh dee dah buh die!!"}, swagLevels = 1000, more = {one = "jeffinitely"}, evenMore = {"hell yeah"}, h = {"yep", h = "h", "wut"}}, {yaml={indent=4}}))
groceries: |
    yummh!
more:
    one: |
        jeffinitely
swagLevels: 1000
greenlands:
    - |
        im green...
    - null
    - null
    - null
    - null
    - |
        ...dah buh dee dah buh die!!
greenland2:
evenMore:
    - |
        hell yeah
h:
    1: |
        yep
    2: |
        wut
    h: |
        h
```