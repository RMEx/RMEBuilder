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

class Package

  class << self

    attr_accessor :all

    def from_list
      list =
        Packages.list.map do |name, args|
          [name, {uri: Http.service_with(args[0]), schema: args[1]}]
        end
      Package.all = Hash[list]
    end

  end

  p from_list
  gets

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
