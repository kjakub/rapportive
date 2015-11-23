# Rapportive - Obsolete and not functional since Rapportive API change

[![Build Status](https://travis-ci.org/kjakub/rapportive.png?branch=master)](https://travis-ci.org/kjakub/rapportive)

## Installation

Add this line to your application's Gemfile:

    gem 'rapportive'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rapportive

## Usage

    1. set it up

    Rapportive.configure do |config|
      //choose one of those method
      config.method = :single_proxy OR :multi_proxy OR :no_proxy

      // if you choose single_proxy set proxy
      config.proxy = "proxy_ip:proxy_port" 

      // if you choose multi_proxy some proxy list are provided in constants.rb
      config.proxy_list = ["proxy_ip:proxy_port","proxy_ip:proxy_port"]
      
      // customize email templates or default is provided in constants.rb
      config.email_templates = ["%{fn}", "%{ln}"]

      //set timeout deafult is 20
      config.timeout = 10

      //set full body response as hash or just email a string (if found) false default

      config.full_body = false
    end

    2. query

    first name, last name, middle name - at least one is required

      Rapportive.lookup('first_name','last_name', 'middle_name', 'gmail.com')

## Contributing

1. Fork it ( http://github.com/<my-github-username>/rapportive/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
