# DryIce - Caching for HTTParty

## Description

Cache responses in HTTParty models. Every response from a resource which has a non 0 max-age header will be cached for the appropriate amount of time in the cache you provide it

## Installation

### RubyGems

You can install the latest Film Buff gem using RubyGems

    gem install dry_ice

### GitHub

Alternatively you can check out the latest code directly from Github

    git clone http://github.com/homeflow/dry_ice.git

## Usage

Any class which includes the `HTTParty` module can include `HTTParty::DryIce` and get access to a cache class method.
    
    class AnAPI

      include HTTParty
      include HTTParty::DryIce
      base_uri 'example.com'
      
      cache Rails.cache

    end

The `cache` method accepts any instance which quacks like a [ActiveSupport cache](http://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html). That means you can use the built in Rails caches, something like [Redis Store](https://github.com/jodosha/redis-store) or your own custom rolled class as long as it responds to the methods: 

   - read
   - write (taking an option :expires_in => seconds)
   - exit?
   - delete


## Contribute

Fork the project, implement your changes in it's own branch, and send
a pull request to me. I'll gladly consider any help or ideas.

### Contributors

- [Daniel Cooper](http://github.com/danielcooper) - For homeflow.co.uk

This project was based off the excellent httparty-icebox gem: https://github.com/sachse/httparty-icebox. It's contributors are listed below.

- [Karel Minarik](http://karmi.cz) (Original creator through [a gist](https://gist.github.com/209521/))
- [Martyn Loughran](https://github.com/mloughran) - Major parts of this code are based on the architecture of ApiCache.
- [David Heinemeier Hansson](https://github.com/dhh) - Other parts are inspired by the ActiveSupport::Cache in Ruby On Rails.
- [Amit Chakradeo](https://github.com/amit) - For pointing out response objects have to be stored marshalled on FS.
- Marlin Forbes - For pointing out the query parameters have to be included in the cache key.
- [ramieblatt](https://github.com/ramieblatt) - Original Memcached store.
