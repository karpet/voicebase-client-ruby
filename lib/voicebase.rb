# VoiceBase.com Ruby SDK
# Copyright 2015 - Pop Up Archive
# Licensed under Apache 2 license - see LICENSE file
#
#

require 'rubygems'
require 'json'
require 'faraday_middleware'
require 'oauth2'
require 'uri'
require 'xmlsimple'

module VoiceBase

  module Error
    class NotFound < StandardError

    end
  end

  class FaradayErrHandler < Faraday::Response::Middleware
    def on_complete(env)
      # Ignore any non-error response codes
      return if (status = env[:status]) < 400
      #puts "got response status #{status}"
      case status
      when 404
        #raise Error::NotFound
        # 404 errors not fatal
      else
        #puts pp(env)
        super  # let parent class deal with it
      end
    end
  end

  class Client

    attr_accessor :api_version
    attr_accessor :host
    attr_accessor :debug
    attr_accessor :agent
    attr_accessor :user_agent
    attr_accessor :cookies
    attr_accessor :api_endpoint
    attr_accessor :croak_on_404
    attr_accessor :language

    def version
      return "1.0.0"
    end

    def initialize(args)
      #puts args.inspect
      @api_version         = args[:api_version] || '1.1'
      @un                  = args[:username]
      @pw                  = args[:password]
      @auth_id             = args[:id]
      @auth_secret         = args[:secret]
      @oauth_redir_uri     = args[:redir_uri] || 'urn:ietf:wg:oauth:2.0:oob'
      @host                = args[:host] || 'https://api.voicebase.com'
      @debug               = args[:debug]
      @user_agent          = args[:user_agent] || 'voicebase-client-ruby/'+version()
      @api_endpoint        = args[:api_endpoint] || '/services'
      @croak_on_404        = args[:croak_on_404] || false
      @language            = args[:language] || 'en'  # US English

      # normalize host
      @host.gsub!(/\/$/, '')

      # sanity check
      begin
        uri = URI.parse(@host)
      rescue URI::InvalidURIError => err
        raise "Bad :host value " + err
      end
      if (!uri.host || !uri.port)
        raise "Bad :host value " + @server
      end

      @agent = get_agent
      @token = get_auth_token
    end

    def get_auth_token
      resp = VoiceBase::Response.new @agent.post('', {
        version: @api_version, 
        apiKey: @auth_id, 
        password: @auth_secret, 
        action: 'getToken', 
        timeout: 1440
      }) 
      resp.token
    end

    def get_agent()
      uri = @host + @api_endpoint
      opts = {
        :url => uri,
        :headers => {
          'User-Agent'   => @user_agent,
          'Accept'       => 'application/json',
          'Cookie'       => @cookies
        }
      }
      conn = Faraday.new(opts) do |faraday|
        faraday.request :url_encoded
        [:mashify, :json].each{|mw| faraday.response(mw) }
        if !@croak_on_404
          faraday.use VoiceBase::FaradayErrHandler
        else 
          faraday.response(:raise_error)
        end
        faraday.response :logger if @debug
        faraday.adapter  :excon   # IMPORTANT this is last
      end

      return conn
    end

    def post(params)
      merged_params = params.merge({version: @api_version, token: @token})
      resp = @agent.post '', merged_params
      return VoiceBase::Response.new resp
    end

    def method_missing(meth, args, &block)
      #STDERR.puts "action=#{meth} args=#{args.inspect}"
      if args.size > 0
        post args.merge({ action: meth })
      else
        post action: meth
      end
    end

  end # end Client

  # dependent classes
  class Response

    attr_accessor :http_resp

    def initialize(http_resp)
      @http_resp = http_resp

      #warn http_resp.headers.inspect
      #warn "code=" + http_resp.status.to_s

      @is_ok = false
      if http_resp.status.to_s =~ /^2\d\d/
        @is_ok = true
      end

    end

    def status()
      return @http_resp.status
    end

    def is_success()
      return @is_ok
    end

    def method_missing(meth, *args, &block)
      if @http_resp.body.respond_to? meth
        @http_resp.body.send(meth, *args, &block)
      else
        super
      end
    end

    def respond_to?(meth)
      if @http_resp.body.respond_to? meth
        true
      else
        super
      end
    end

  end # end Response

end # end module

