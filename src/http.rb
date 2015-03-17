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
  ConnectionState         = Win32API.new('wininet', 'InternetGetConnectedState', 'ii', 'i')

  # Exception
  class HttpOpenException < Exception; end
  class HttpConnectException < Exception; end
  class HttpOpenRequestException < Exception; end
  class HttpSendException < Exception; end
  class HttpReceiveException < Exception; end
  class HttpQueryException < Exception; end
  class HttpRead < Exception; end

  class << self

    def connected?
      ConnectionState.call(0, 0) == 1
    end

    def open
      result = HttpOpen.call('', 0, '', '', 0)
      raise HttpOpenException unless result
      result
    end

    def connect(opened, prefix, port)
      result = HttpConnect.call(opened, prefix.to_ws, port, 0)
      raise HttpConnectException unless result
      result
    end

    def open_request(connected, path)
      result = HttpOpenRequest.call(
        connected,
        'GET'.to_ws,
        path.to_ws,
        'HTTP/1.1'.to_ws,
        '',
         0,
         0x00800000
      )
      raise HttpOpenRequestException unless result
      result
    end

    def send_request(opened_request)
      result = HttpSendRequest.call(opened_request, 0, 0, 0, 0, 0, 0)
      raise HttpSendException unless result
      result
    end

    def receive_response(opened_request)
      result = HttpReceiveResponse.call(opened_request, nil)
      raise HttpReceiveException unless result
      result
    end

    def query_available?(opened_request)
      result = HttpQueryDataAvailable.call(opened_request, 0)
      raise HttpQueryException unless result
      result
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
      clean
    end

    def clean
      @variables = {}
    end

    def set_variable(varname, value)
      @variables[varname] = value
    end

    alias_method(:[]=, :set_variable)
    alias_method(:build_query, :variables=)

    def complete_path(prefix = '')
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
      result      = ""
      if complete
        protocol  = PROTOCOL[@port] || :http
        result    = "#{protocol}://"
      end
      result      += prefix
      if !PROTOCOL.keys.include?(@port) && complete
        result    += ":#{@port}"
      end
      complete_path(result)
    end

    def process_query
      result      = ""
      opened      = Http.open
      connection  = Http.connect(opened, @prefix, @port)
      request     = Http.open_request(connection, complete_path)
      Http.send_request(request)
      Http.receive_response(request)
      if Http.query_available?(request)
        buffer = [].pack("x#{Utils.max_request_size}")
        output = [].pack('x4')
        HttpReadData.call(request, buffer, Utils.max_request_size, output)
        len = output.unpack('i!')[0]
        result = buffer[0, len]
      end
      HttpCloseHandle.call(opened)
      HttpCloseHandle.call(connection)
      HttpCloseHandle.call(request)
      clean
      result
    end
    private :process_query

    # Process an HTTP request on the service
    def get
      process_query
    end

  end
end
