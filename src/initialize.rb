# -*- coding: utf-8 -*-
=begin
RMEBuilder - Initialize
Copyright (C) 2015 Nuki <xaviervdw AT gmail DOT com>
Copyright (C) 2015 Joke <joke AT biloucorp DOT com>

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
    Builder.to_install = {}
    Builder.stack_error = []
    Builder.schema_final = []
  end
end

module Kernel
  def restart
    path = 'start "" "' + File.realpath('../bin/Game.exe') + '" console'
    Thread.new { system(path) }
    sleep(0.1)
    Process.exit!(true)
  end
  def force_update
    Builder.force_update = true
  end
  def save_build_schema
    r = ""
    Builder.to_install.each do |name, type|
      r += "package(#{(type == :inline)? "inline " : ""}'#{name}')\n"
    end
    FileTools.write(SCHEMA, r, 'w')
  end
  def package(name)
    kname = name.is_a?(Array) ? name : [:std, name]
    Builder.to_install[kname[1]] = kname[0]
    save_build_schema
  end
  def prepend(name)
    kname = name.is_a?(Array) ? name : [:std, name]
    Builder.to_install = {kname[1] => kname[0]}.merge(Builder.to_install)
    save_build_schema
  end
  alias_method :append, :package
  def inline(name)
    [:inline, name]
  end

  def show_schema
    puts "\n\tbuild-schema.rb:\n"
    Builder.to_install.each do |name, type|
      Console.refutable "\t#{name} #{(type == :inline) ? "(inline)" : ""}"
    end
  end
end

FW_LIST = Http::Service.new(
  prefix: 'raw.githubusercontent.com',
  port: 443,
  path: ['RMEx', 'RMEPackages', 'master', 'packages.rb']
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

def target_selection
  if File.exist?("../last_waypoint.rb")
    current = File.read("../last_waypoint.rb")
    Console.refutable "\n\tCurrent target: \"#{current}\"\n"
    Console.warning "\nChange the target ? (Y/N)"
    return unless gets.chomp.upcase == "Y"
  end
  Console.refutable "\nPlease chose a project folder..."
  result = Browser.launch.split('\\').join(File::SEPARATOR)
  if result == ""
    Console.alert "No directory selected."
    Console::SetFG.call(Console::GetConsole.call)
    target_selection
  else
    FileTools.write("../last_waypoint.rb", result, 'w')
    Console.success "\n\tNew target: #{result}\n"
    Console.warning "\nRMEBuilder need to restart. Press <ENTER> to restart the software!\n"
    Console::SetFG.call(Console::GetConsole.call)
    gets
    restart
  end
end

def prompt
  Console.show_logo
  loop do
    print "RMEBuilder> "
    result = gets.chomp
    case result

    when 'schema', 'show schema' then
      show_schema

    when 'restart' then
      restart

    when /remove (.*)/ then
      if Builder.to_install.delete($1)
        save_build_schema
        Console.success "\n\t#{$1} has been removed.\n"
        show_schema
      else
        Console.alert "\n\t#{$1} is not in the package stack.\n"
      end

    when /move (.*) (up|down)/
      name = $1
      pos = $2
      if Builder.to_install.has_key?(name)
        a = Builder.to_install.to_a
        junction = a.index {|k| k[0] == name}
        elt = a.delete(a[junction])
        f = junction + ((pos == "up") ? -1 : 1)
        a.insert(f, elt)
        Builder.to_install = Hash[a]
        save_build_schema
        Console.success "\n\t#{name} has been moved #{pos}.\n"
        show_schema
      else
        Console.alert "\n\t#{$1} is not in the package stack.\n"
      end

    when /(append|prepend|add) (.*)/ then
      f = $2.split.map do |k|
        unless k == 'inline'
          then "'#{k}'"
          else k end
      end
      meth = ($1 == "add") ? (($2 == "RME") ? "prepend" : "append") : $1
      res = eval(f.join(' '))
      name = res.is_a?(Array) ? res[1] : res
      unless Builder.to_install.has_key?(name)
        Kernel.send(meth, res)
        Console.success "\n\t#{name} has been added.\n"
        show_schema
      else
        Console.warning "\n\t#{name} is already in the package list.\n"
      end

    when /show all.*/, 'show' then
      puts ""
      Packages.all.keys.sort_by{|a| a.downcase}.each do |pkg|
        if Packages.locals.has_key?(pkg)
          Console.success "\t#{pkg}"
        else
          Console.refutable "\t#{pkg}"
        end
      end

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

    when 'download 100k_bank_account' then
      Console.alert "\n\tI'm the NSA and I SEE YOU"

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

    when '--quit', 'quit', 'exit' then exit

    when 'purge' then
      FileTools.remove_recursive(REP_PATH, true)
      init

    when /ah!?.*/i then Console.warning "\n\tDoes that mean that women can't build a hut ?\n\n"

    when /build\s*(.*)/ then
      f = $1 == "dev"
      Builder.stack_error = []
      Builder.schema_final = []
      Builder.to_install.each do |name, type|
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

    when 'target', 'define target', 'set target' then target_selection

    when *S[0..2] then
      Console.refutable "RMEBuilder> " + S[a=rand(3)]
      Kernel.sleep(0.5)
      Console.print_color("\n\t"+S[3+b=(S.index(result)-a)%3], S[6+b])
      Console.print_color(" [#{S[9] += b%2}-#{S[10] += b/2}]\n", 8)

    when 'about' then puts ''; ABOUT.each {|line| Console.refutable "\t"+line}

    when /about (.*)/
      then Package.get_info($1)

    when '--help', 'help', 'h' then
      puts ""
      Console.two_colors "\tBuild project target:\t", "target\n", 0x0008, 0x000e
      puts ""
      Console.two_colors "\tShow all packages:\t", "show\n", 0x0008, 0x000e
      puts ""
      Console.two_colors "\tInfo about a package:\t", "about <package-name>\n", 0x0008, 0x000e
      puts ""
      Console.two_colors "\tAdd package to schema:\t", "add <package-name>\n", 0x0008, 0x000e
      Console.two_colors "\t\t\t\t", "append <package-name>\n", 0x0008, 0x000e
      Console.two_colors "\t\t\t\t", "prepend <package-name>\n", 0x0008, 0x000e
      Console.refutable "\t\t\t\tPossible option 'inline'.\n"
      Console.refutable "\t\t\t\tSample: add inline <package-name>\n"
      puts ""
      Console.two_colors "\tMove up/down package:\t", "move <package-name> up|down\n", 0x0008, 0x000e
      Console.two_colors "\tUpdate a package:\t", "update <package-name>\n", 0x0008, 0x000e
      Console.two_colors "\tClone a package:\t", "clone <package-name>\n", 0x0008, 0x000e
      Console.two_colors "\tReclone a package:\t", "reclone <package-name>\n", 0x0008, 0x000e
      Console.two_colors "\tRemove a package:\t", "remove <package-name>\n", 0x0008, 0x000e
      puts ""
      Console.two_colors "\tShow build schema:\t", "schema\n", 0x0008, 0x000e
      puts ""
      Console.two_colors "\tBuild schema to project: ", "build\n", 0x0008, 0x000e
      puts ""
      Console.two_colors "\tQuit:\t\t\t", "quit\n", 0x0008, 0x000e
      Console.two_colors "\tRestart:\t\t", "restart\n", 0x0008, 0x000e
    else
      Console.refutable "Enter 'help' for informations"
    end
    puts ""
  end
end

def check_for_updates
  return unless Http.connected?
  path = Http::Service.new(
    prefix: 'raw.githubusercontent.com',
    port: 443,
    path: ['RMEx', 'RMEBuilder', 'master']
  )
  path_vsn = path.clone
  path_vsn << "current_version.rb"
  oth_version = eval(path_vsn.get)
  return if oth_version == CURRENT_VERSION
  Console.success "A new version of RMEBuilder (#{oth_version}) is available. \nUPGRADE(Y/N)?\n"
  if gets.chomp.upcase == "Y"
    COMPONENTS.each do |f|
      File.delete(SRC_PATH.addSlash + f)
      Console.refutable "\t#{f} is purged\n"
    end
    path_comp = path.clone
    path_comp << "components.rb"
    new_components = eval(path_comp.get)
    path_src = path.clone
    path_src << "src"
    new_components.each do |src_f|
      path_file = path_src.clone
      path_file << src_f
      content = path_file.get
      fname = "#{SRC_PATH.addSlash}#{src_f}"
      FileTools.write(fname, content, 'w')
      Console.success "\t#{fname} is downloaded\n"
    end
    Console.success "\nRMEBuilder is up to date ! Press <ENTER> to restart the software!\n"
    gets
    restart
  end
end
