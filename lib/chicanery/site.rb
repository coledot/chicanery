require 'net/http'
require 'openssl'
require 'benchmark'

module Chicanery
  class Site
    attr_reader :name, :uri, :options, :body, :code, :duration

    def initialize name, url, options={}
      @name, @uri, @options = name, URI(url), options
    end

    def path
      uri.query ? "#{uri.path}?#{uri.query}" : uri.path
    end

    def get
      req = Net::HTTP::Get.new path
      req.basic_auth options[:user], options[:password] if options[:user] and options[:password]
      http_opts = {
        use_ssl:      uri.scheme == 'https',
        open_timeout: 5,
        read_timeout: 5,
        ssl_timeout:  5,
      }
      http_opts[:verify_mode] = OpenSSL::SSL::VERIFY_NONE unless options[:verify_ssl]
      start = Time.now
      res = Net::HTTP.start uri.host, uri.port, http_opts do |https|
        https.request req
      end
      @duration, @code, @body = (Time.now - start), res.code, res.body
      res.value #check for success via a spectactularly poorly named method
      res.body
    end
  end
end
