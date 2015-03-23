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

def init
  FileTools.safe_mkdir(REP_PATH)
  Sync.from_funkywork
  Utils.load(REP_LIST)
end
init

def perform(name)
  begin
    yield(name)
  rescue UnboundPackage
    puts ""
    k = Packages.all.keys.sort_by {|a| a.downcase.leven(name)}
    Console.alert "\t\"#{name}\" is not an existant package."
    Console.refutable "\tDid you mean maybe \"#{k[0]}\" ?"
  end
end

def prompt
  Console.show_logo
  loop do
    print "RMEBuilder> "
    result = gets.chomp
    case result

    when /show all.*/, 'show' then
      puts ""
      Packages.all.keys.sort_by{|a| a.downcase}.each do |pkg|
        if Packages.locals.has_key?(pkg)
          Console.success "\t#{pkg}"
        else
          Console.refutable "\t#{pkg}"
        end
      end

    when /download (.*) --force-update/, /update (.*)/
      then perform($1){|n| Package.download(n, REP_PATH, true)}

    when /clone (.*) --force-update/, /reclone (.*)/
      then perform($1){|n| Package.clone(n, true)}

    when /download (.*)/
      then perform($1){|n| Package.download(n)}

    when /clone (.*)/
      then perform($1){|n| Package.clone(n)}

    when '--quit', 'quit' then exit

    when '--help', 'help' then
      puts ""
      Console.two_colors "\tDownload a package:\t", "download <package-name>\n", 0x0008, 0x000e
      Console.two_colors "\tClone a package:\t", "clone <package-name>\n", 0x0008, 0x000e
      Console.two_colors "\tUpdate a package:\t", "update <package-name>\n", 0x0008, 0x000e
      Console.two_colors "\tReclone a package:\t", "reclone <package-name>\n", 0x0008, 0x000e
      Console.two_colors "\tShow all packages:\t", "show all\n", 0x0008, 0x000e
      Console.two_colors "\tQuit:\t\t\t", "quit\n", 0x0008, 0x000e
    else
      Console.refutable "enter --help for informations"
    end
    puts ""
  end
end
