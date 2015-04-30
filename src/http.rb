# -*- coding: utf-8 -*-
=begin
RMEBuilder - Http
Copyright (C) 2015 Nuki <xaviervdw AT gmail DOT com>

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.
This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.
You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
=end

module Http

  PROTOCOL = {
    21    => :ftp,
    80    => :http,
    443   => :https
  }

  # Win32API
  HttpOpen                = Win32API.new('winhttp','WinHttpOpen','pippi','i')
  HttpConnect             = Win32API.new('winhttp','WinHttpConnect','ppii','i')
  HttpOpenRequest         = Win32API.new('winhttp','WinHttpOpenRequest','pppppii','i')
  HttpSendRequest         = Win32API.new('winhttp','WinHttpSendRequest','piiiiii','i')
  HttpReceiveResponse     = Win32API.new('winhttp','WinHttpReceiveResponse','pp','i')
  HttpQueryDataAvailable  = Win32API.new('winhttp','WinHttpQueryDataAvailable', 'pi', 'i')
  HttpReadData            = Win32API.new('winhttp','WinHttpReadData','ppip','i')
  HttpCloseHandle         = Win32API.new('winhttp','WinHttpCloseHandle', 'p','i')
  ConnectionState         = Win32API.new('wininet','InternetGetConnectedState', 'ii', 'i')
  URLDownloadToFile       = Win32API.new('urlmon', 'URLDownloadToFile', 'LPPLL', 'L')

  # Exception
  Utils.define_exception :HttpOpenException
  Utils.define_exception :HttpConnectException
  Utils.define_exception :HttpOpenRequestException
  Utils.define_exception :HttpSendException
  Utils.define_exception :HttpReceiveException
  Utils.define_exception :HttpQueryException
  Utils.define_exception :HttpRead

  class << self

    def connected?
      ConnectionState.call(0, 0) == 1
    end

    def download_file(from, to)
      URLDownloadToFile.call(0, from, to, 0, 0).zero?
    end

    def open
      session = HttpOpen.call('', 0, '', '', 0)
      raise HttpOpenException unless session
      session
    end

    def connect(opened, prefix, port)
      connection = HttpConnect.call(opened, prefix.to_ws, port, 0)
      raise HttpConnectException unless connection
      connection
    end

    def open_request(connected, path)
      request = HttpOpenRequest.call(
        connected,
        'GET'.to_ws,
        path.to_ws,
        'HTTP/1.1'.to_ws,
        '',
         0,
         0x00800000
      )
      raise HttpOpenRequestException unless request
      request
    end

    def send_request(opened_request)
      sender = HttpSendRequest.call(opened_request, 0, 0, 0, 0, 0, 0)
      raise HttpSendException unless sender
      sender
    end

    def receive_response(opened_request)
      reception = HttpReceiveResponse.call(opened_request, nil)
      raise HttpReceiveException unless reception
      reception
    end

    def query_available?(opened_request)
      HttpQueryDataAvailable.call(opened_request, 0)
    end

    def service_with(str)
      protocol, rest  = str.split('://')
      rest, protocol  = protocol, 'http' unless rest
      protocol        = protocol.to_sym
      rest, vars      = rest.split('?')
      vars            ||= ""
      vars            = vars.split('&').map {|k| k.split('=')}
      prefix, *path   = rest.split('/')
      path, prefix    = prefix, [] unless path
      prefix, port    = prefix.split(':')
      port            ||= PROTOCOL.key(protocol)
      Http::Service.new(
        prefix: prefix,
        path: path,
        port: port.to_i,
        variables: vars
      )
    end

  end

  # Represent a callable HTTP service
  class Service

    attr_accessor :prefix
    attr_accessor :path
    attr_accessor :variables
    attr_accessor :port

    def initialize(hash)
      @prefix     = hash[:prefix]
      @path       = hash[:path] || []
      @port       = hash[:port] || 80
      @variables  = hash[:variables] || {}
    end

    def clone
      Service.new(
        prefix: @prefix.dup,
        path: @path.dup,
        port: @port,
        variables: @variables.dup
      )
    end

    def clean
      @variables = {}
    end

    def set_variable(name, value)
      @variables[name] = value
    end

    alias_method(:[]=, :set_variable)
    alias_method(:build_query, :variables=)

    def add_directory(name)
      @path << name
    end

    alias_method(:<<, :add_directory)

    def base_uri(prefix = '')
      path    = @path.join('/')
      prefix  += '/' unless path == ''
      prefix  += path
      unless @variables.empty?
        result    += '?'
        vars      = @variables.to_a.map {|k, v| "#{k}=#{v}"}
        prefix    += vars.join('&')
      end
      prefix
    end

    def uri(complete = false)
      uri_str     = ""
      if complete
        protocol  = PROTOCOL[@port] || :http
        uri_str   = "#{protocol}://"
      end
      uri_str     += prefix
      if !PROTOCOL.keys.include?(@port) && complete
        uri_str   += ":#{@port}"
      end
      base_uri(uri_str)
    end

    def process_query
      opened      = Http.open
      connection  = Http.connect(opened, @prefix, @port)
      request     = Http.open_request(connection, base_uri)
      response    = yield(request) if block_given?
      HttpCloseHandle.call(opened)
      HttpCloseHandle.call(connection)
      HttpCloseHandle.call(request)
      clean
      response
    end
    private :process_query

    # Process an HTTP request on the service
    def get
      process_query do |request|
        Http.send_request(request)
        Http.receive_response(request)
        if Http.query_available?(request)
          buffer = [].pack("x#{Utils.max_request_size}")
          output = [].pack('x4')
          HttpReadData.call(request, buffer, Utils.max_request_size, output)
          len = output.unpack('i!')[0]
          return buffer[0, len]
        end
        raise HttpQueryException
      end
    end

  end
end
