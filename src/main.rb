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
Graphics.resize_screen(1, 1)

# Source folder
SRC_PATH    = '../src'
REP_PATH    = '../.local'
REP_LIST    = REP_PATH + '/list.rb'
REP_TRACE   = REP_PATH + '/trace.rb'
CUSTOM_PATH = '../customPackages'
CURRENT_VERSION = vsn(2, 0, 0)
# Inner modules
Kernel.send(:require, SRC_PATH+'/utils.rb')
Utils.load('../target.rb')
SCRIPT_RVDATA = '../'+TARGET.addSlash+"Data/Scripts.rvdata2"
Utils.load('console.rb')
Utils.load('http.rb')
Utils.load('version.rb')
Utils.load('compiler.rb')
Utils.load('initialize.rb')
Utils.load('package.rb')
Utils.load('../'+TARGET.addSlash + SCHEMA)

FileTools.write("../current_version.rb", CURRENT_VERSION.raw_inspect, flag = "w")
check_for_updates
prompt
