# JSON5

JSON5 parser for Ruby

## Installation

Add this line to your application's Gemfile:

    gem 'json5'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json5

## Usage

```js
JSON5.parse(<<-JSON5)
{
    foo: 'bar',
    while: true,

    this: 'is a \
multi-line string',

    // this is an inline comment
    here: 'is another', // inline comment

    /* this is a block comment
       that continues on another line */

    hex: 0xDEADbeef,
    half: .5,
    delta: +10,
    to: Infinity,   // and beyond!

    finally: 'a trailing comma',
    oh: [
        "we shouldn't forget",
        'arrays can have',
        'trailing commas too',
    ],
}
JSON5

```

See http://json5.org/ for details

## Contributing

1. Fork it ( http://github.com/bartoszkopinski/json5/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
