# -*- coding: utf-8 -*-
=begin
RMEBuilder - Main
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

# Source folder
SRC_PATH  = '../src'
REP_PATH  = '../.local'

# Inner modules
Kernel.send(:require, SRC_PATH+'/utils.rb')
Utils.load('console.rb')
Utils.load('http.rb')
Utils.load('initialize.rb')

# Define destination folder
Utils.load('../target.rb')
def folder_target; '../'+TARGET.addSlash; end
def build_schema; folder_target + SCHEMA; end
Utils.load(build_schema)
