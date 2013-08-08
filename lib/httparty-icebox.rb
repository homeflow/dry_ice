require 'logger'
require 'fileutils'
require 'tmpdir'
require 'pathname'
require 'digest/md5'

module HTTParty #:nodoc:
  # == Caching for HTTParty
  # See documentation in HTTParty::Icebox::ClassMethods.cache
  #
  module Icebox

    module ClassMethods

      # Enable caching and set cache options
      # Returns memoized cache object
      #
      # Following options are available, default values are in []:
      #
      # +store+::       Storage mechanism for cached data (memory, filesystem, your own) [memory]
      # +timeout+::     Cache expiration in seconds [60]
      # +logger+::      Path to logfile or logger instance [nil, silent]
      #
      # Any additional options are passed to the Cache constructor
      #
      # Usage:
      #
      #   # Enable caching in HTTParty, in memory, for 1 minute
      #   cache # Use default values
      #
      #   # Enable caching in HTTParty, on filesystem (/tmp), for 10 minutes
      #   cache :store => 'file', :timeout => 600, :location => '/tmp/'
      #
      #   # Use your own cache store (see +AbstractStore+ class below)
      #   cache :store => 'memcached', :timeout => 600, :server => '192.168.1.1:1001'
      #
      def cache(cache)
        return @cache = nil unless cache
        raise "cache instance must respond_to #read, #write and #delete" unless cache.respond_to?(:read) && cache.respond_to?(:write) && cache.respond_to?(:delete)
        @cache = IceCache.new(cache)
      end

      def get_cache
        @cache || false
      end

    end

    # When included, extend class with +cache+ method
    # and redefine +get+ method to use cache
    #
    def self.included(receiver) #:nodoc:
      receiver.extend ClassMethods
      receiver.class_eval do

        # Get reponse from network
        #
        # TODO: Why alias :new :old is not working here? Returns NoMethodError
        #
        def self.get_without_caching(path, options={})
          perform_request Net::HTTP::Get, path, options
        end

        # Get response from cache, if available
        #
        def self.get_with_caching(path, options={})
          return get_without_caching(path, options) unless get_cache
          key = path.downcase # this makes a copy of path
          key << options[:query].to_s if defined? options[:query]
          if res = get_cache.read(key) 
            return res
          else
            response =  get_without_caching(path, options)
            if cache_for = self.cache_response?(response)
              get_cache.write(key,response, :expires_in => cache_for)
              return response
            else
              return response
            end
          end
        end

        #returns falsy if the response should not be cached - otherwise returns the timeout in seconds to cache for
        def self.cache_response?(response)
           return false if !response.body
           return false unless response.code.to_s == "200"
           timeout = response.headers['cache-control'] && response.headers['cache-control'][/max-age=(\d+)/, 1].to_i()
           return false unless timeout && timeout != 0
           return timeout
        end

        # Redefine original HTTParty +get+ method to use cache
        #
        def self.get(path, options={})
          self.get_with_caching(path, options)
        end

      end
    end

    class IceCache

      require 'msgpack'

      def initialize(cache)
        @cache = cache
      end

      def write(name, value, options = {})
        @cache.write(name, serialize_response(value), options)
      end


      def serialize_response(response)
        headers = response.headers.dup
        body = response.body.dup
        [headers,body].to_msgpack 
      end

      def build_response(serialized_response)
        res = MessagePack.unpack(serialized_response)
        CachedHTTPartyResponse.new(res[0], res[1])
      end

      def read(*args)
        found = @cache.read(*args)
        build_response(found) if found
      end

      def exist?(*args)
        @cache.exist?(*args)
      end


    end

    class CachedHTTPartyResponse

      attr_accessor :headers, :body

      def initialize(headers, body)
        @headers, @body = headers, body
      end

    end

  end
end

