# -*- coding: utf-8 -*-
=begin
RMEBuilder - Initialize
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

FW_LIST = Http::Service.new(
  prefix: 'raw.githubusercontent.com',
  port: 443,
  path: ['funkywork', 'RMEPackages', 'master', 'packages.rb']
)

module Sync
  extend self

  def from_funkywork
    header  = "\# Loaded from #{FW_LIST.uri(true)} at #{Time.now}\n"
    list    = FW_LIST.get
    File.open(REP_LIST, 'w') do |file|
      file.write(header + list)
    end
  end

end

# Create repositories folder (unless exists)
def init
  Package.installed = {}
  unless Dir.exists?(CUSTOM_PATH)
    Dir.mkdir(CUSTOM_PATH)
  end
  if File.exist?(REP_TRACE)
    Package.installed = eval(FileTools.read(REP_TRACE))
  end
  unless Dir.exist?(REP_PATH)
    Dir.mkdir(REP_PATH)
    # Syncronize
    Sync.from_funkywork
    # Load the repositories list
    Utils.load(REP_PATH.addSlash + 'list.rb')
  end
end
init

def prompt
  Console.clear
  print "RMEBuilder\n\n\n"
  print "1.)\tLoad packages\n"
  print "2.)\tPurge packages\n"
  print "3.)\tAvailable packages\n"
  print "4.)\tUpdate packages list\n"
  print "5.)\tUpdate installed packages\n"
  puts "\n"
  print 'Choice [enter for exit]> '
  choice = gets.chomp
  case choice
  when "1", "build" then
    Console.clear
    Utils.load(build_schema)
    puts "\n\nEverything is downloaded"
  when "2", "purge" then
    Package.purge
    puts "\n\nAll packages are deleted"
  when "3", "show" then
    Console.clear
    Package.show_all
  when "4", "update" then
    Console.clear
    Sync.from_funkywork
    puts "\n\nList is up to date\n"
    Package.show_all
  when "5", "rebuild" then
    Console.clear
    Package.purge
    Sync.from_funkywork
    Utils.load(build_schema)
    puts "\n\nEverything is downloaded"
    puts "\n\nList is up to date\n"
  when /download (.*)/ then Package.download($1)
  when /clone (.*)/ then
    d = CUSTOM_PATH.addSlash+$1.addSlash
    Utils.remove_recursive(d, true) if Dir.exist?(d)
    Package.download($1, d)
  else exit
  end
  puts "\n\nPress [ENTER]"
  gets
end
