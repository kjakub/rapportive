# Rapportive

[![Build Status](https://travis-ci.org/kjakub/rapportive.png?branch=master)](https://travis-ci.org/kjakub/rapportive)

## Installation

Add this line to your application's Gemfile:

    gem 'rapportive'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rapportive

## Usage

    without predefined set of proxies: PROXY OFF

      Rapportive.lookup('jakub','kuchar','gmail.com', false)

    with predefined set of proxies: PROXY ON

      Rapportive.lookup('jakub','kuchar','gmail.com', true)

## Contributing

1. Fork it ( http://github.com/<my-github-username>/rapportive/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
