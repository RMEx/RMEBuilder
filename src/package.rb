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

  class << self

    attr_accessor :all
    attr_accessor :installed
    attr_accessor :insert_after

    def purge
      Utils.remove_recursive(REP_PATH, true) if Dir.exist?(REP_PATH)
      init
    end

    def from_list
      list =
        Packages.list.map do |name, url|
          args    = url.split('/')
          schema  = args.pop
          uri     = args.join('/')
          [name, {uri: Http.service_with(uri), schema: schema}]
        end
      Package.all = Hash[list]
    end

    def add(name)
      Package.from_list
      Package.installed ||= []
      unless Package.all.has_key?(name)
        raise UnboundPackage, "Unknown package #{name}"
      end
      install(name) unless Dir.exist?(REP_PATH.addSlash + name)
    end

    def install(name)
      p "Download #{name}"
      repo        = (REP_PATH.addSlash + name).addSlash
      Dir.mkdir(repo)
      pkg         = Package.all[name]
      schema_uri  = pkg[:uri].clone
      schema_uri  << pkg[:schema]
      schema_ctn  = schema_uri.get
      File.open(repo+pkg[:schema], 'w') { |f| f.write(schema_ctn) }
      pkg_data    = eval(schema_ctn)
      pkg_data.components.each do |c_name|
        full_name = repo + c_name
        init_uri  = pkg[:uri].clone
        init_uri  << c_name
        File.open(full_name, 'w') { |f| f.write(init_uri.get) }
        p "#{full_name} installed"
      end
      Package.installed << name
      File.open(REP_TRACE, 'w') { |f| f.write(Package.installed.to_s)}
      p "#{name} is installed"
    end

  end

  attr_accessor :name
  attr_accessor :version
  attr_accessor :components
  attr_accessor :dependancies
  attr_accessor :description
  attr_accessor :authors
  attr_accessor :uri
  attr_accessor :schema

  def initialize(hash)
    @name         = hash[:name]
    @version      = hash[:version]      || vsn
    @components   = hash[:components]   || {}
    @dependancies = hash[:dependancies] || []
    @authors      = hash[:authors]      || {}
    @description  = hash[:description]  || ""
  end
end

module Kernel

  def add_package(name)
    Package.add(name)
  end

end
