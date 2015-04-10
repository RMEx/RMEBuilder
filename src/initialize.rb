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

class Builder
  class << self
    attr_accessor :force_update
    attr_accessor :to_install
    attr_accessor :stack_error
    attr_accessor :schema_final
    Builder.force_update = false
    Builder.to_install = []
    Builder.stack_error = []
    Builder.schema_final = []
  end
end

module Kernel
  def force_update
    Builder.force_update = true
  end
  def package(name)
    kname = name.is_a?(Array) ? name : [:std, name]
    Builder.to_install << kname
  end
  def inline(name)
    [:inline, name]
  end
end

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
    Builder.stack_error << [name, :unbound]
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

    when 'download 100k_bank_account' then
      Console.alert "\n\tI'm the NSA and I SEE YOU"

    when 'download_according_schema', 'download *' then
      Builder.to_install.each {|k| perform(k) do
        |n|
        n = n[1] if k.is_a?(Array)
        Package.download(n)
      end}

    when 'update_according_schema', 'update *' then
      Builder.to_install.each {|k| perform(k) do
        |n|
        n = n[1] if k.is_a?(Array)
        Package.download(n, REP_PATH, true)
      end}

    when /download (.*) --force-update/, /update (.*)/
      then perform($1){|n| Package.download(n, REP_PATH, true)}

    when /clone (.*) --force-update/, /reclone (.*)/
      then perform($1){|n| Package.clone(n, true)}

    when /download (.*)/
      then perform($1){|n| Package.download(n)}

    when 'have fun' then
      Console.clear
      Kernel.sleep(0.5)
      Console.show_logo

    when 'doctor' then
      Console.warning "\n\t Hi, i'm RMEDoctor, I'm really useless and i Have some bugs :D ...\n\n"
      q = ""
      while (q != 'quit')
        print "Ask me a question> "
        q = gets.chomp
        Console.warning "\n\t#{Doctor.answer(q)}\n\n"
      end
      Console.warning "\n\tSee you soon :D\n\n"
    when /clone (.*)/
      then perform($1){|n| Package.clone(n)}

    when '--quit', 'quit' then exit

    when 'purge' then
      FileTools.remove_recursive(REP_PATH, true)
      init

    when /Ah.*/ then Console.warning "\n\tThe women could'nt make cabane?\n\n"

    when /build\s*(.*)/ then
      f = $1 == "dev"
      Builder.stack_error = []
      Builder.schema_final = []
      Builder.to_install.each do |type, name|
        if Dir.exist?(CUSTOM_PATH.addSlash+name)
          Console.refutable "Grep RME"
          Builder.schema_final << [:custom, type, name]
          Console.success "\t#{name} is locally present"
        else
          perform(name){|n| Package.download(n)}
          Builder.schema_final << [:local, type, name]
        end
      end
      if Builder.stack_error.length > 0 then
        puts ""
        Console.alert "\tBuild failure for this packages\n"
        Builder.stack_error.each {|k, v| Console.refutable "\t\t* #{k}"}
      else
        Compiler.start(f)
      end

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

def check_for_updates
  return unless Http.connected?
  pushed_version_str = Http::Service.new(
    prefix: 'raw.githubusercontent.com',
    port: 443,
    path: ['funkywork', 'RMEBuilder', 'master', 'current_version.rb']
  ).get
  oth_version = eval(pushed_version_str)
  return if oth_version == CURRENT_VERSION
  Console.warning "A new version of RMEBuilder (#{oth_version}) is available, UPGRADE(Y/N)?"
  if gets == "Y"

  end
end
