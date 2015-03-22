# -*- coding: utf-8 -*-
=begin
RMEBuilder - Package
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

Utils.define_exception :UnboundPackage

class Package

  attr_accessor :name
  attr_accessor :version
  attr_accessor :components
  attr_accessor :dependancies
  attr_accessor :exclude
  attr_accessor :description
  attr_accessor :authors
  attr_accessor :uri
  attr_accessor :schema

  def initialize(hash)
    @name         = hash[:name]
    @version      = hash[:version]      || vsn
    @components   = hash[:components]   || {}
    @dependancies = hash[:dependancies] || {}
    @exclude      = hash[:exclude]      || []
    @authors      = hash[:authors]      || {}
    @description  = hash[:description]  || ""
  end

  def serialize
    "Package.new(name:#{@name}, version:#{@version}," +
    " dependancies:#{@dependancies}, authors: #{@authors}," +
    "description: #{@description})"
  end
end


module Packages
  attr_accessor :locals, :all
  Packages.locals =
    (File.exist?(REP_TRACE)) ?
    (Hash[FileTools.eval_file(REP_TRACE)].map {|k,v| [k, eval(v)]}) : {}

  def exist?(name)
    list.has_key?(name)
  end

  def map
    list =
      Packages.list.map do |name, url|
        args    = url.split('/')
        schema  = args.pop
        uri     = args.join('/')
        [name, {uri: Http.service_with(uri), schema: schema}]
      end
    Packages.all = Hash[list]
  end
  map

end


class Package

  class << self

    def exist?(name)
      Packages.exist?(name)
    end

    def download(name, target = REP_PATH, update = false)
      raise UnboundPackage unless exist?(name)
      package = Packages.all[name]
      puts "Download #{name}"
      Console.refutable "From #{Packages.list[name]}"
      FileTools.safe_mkdir(target)
      target = target.addSlash + name.addSlash
      if update
        Console.warning "\tSuppress #{target} for redownload"
        FileTools.safe_rmdir(target)
      else
        if Dir.exist?(target)
          Console.alert "\t#{target} already exist"
          puts ""
          return
        end
      end
      Console.success "\tCreate #{target}"
      Dir.mkdir(target)
      uri = package[:uri].clone
      uri << package[:schema]
      schema_content = uri.get
      FileTools.write(target + package[:schema], schema_content, 'w')
      Console.success "\tSchema is downloaded"
      schema = eval(schema_content)
      schema.components.each do |c_name|
        full_name = target + c_name
        init_uri = package[:uri].clone
        init_uri << c_name
        FileTools.write(full_name, init_uri.get, 'w')
        Console.success "\t#{full_name} is downloaded"
      end
      resolve_dependancies(schema)
      Packages.locals[name] = schema
      rep = Hash[Packages.locals.map {|k, v| [k, schema_content]}]
      FileTools.write(REP_TRACE, rep, 'w')
      Console.success "#{name} is downloaded !"
      puts ""
    end

    def resolve_dependancies(schema)
      schema.dependancies.each {|pkg| download(pkg)}
    end

  end

end
