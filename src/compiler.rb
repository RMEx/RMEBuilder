# -*- coding: utf-8 -*-
=begin
RMEBuilder - Compiler
Copyright (C) 2015 Nuki <xaviervdw AT gmail DOT com>
Copyright (C) 2015 Grim <grimfw AT gmail DOT com>

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

module Compiler
  extend self

  PACK = Struct.new(:repo, :type, :desc, :composants)

  attr_accessor :dev
  attr_accessor :output
  attr_accessor :source_tree
  attr_accessor :max_id
  attr_accessor :compiled_data
  attr_accessor :bytes

  def empty_line?(o); o[1] == "" && o[2] == EMPTY; end

  def deflate(content)
    docker  = Zlib::Deflate.new(Zlib::BEST_COMPRESSION)
    data    = docker.deflate(content, Zlib::FINISH)
    docker.close
    data
  end

  def empty_script_line
    self.max_id += 1
    self.bytes << [self.max_id, "", deflate("")]
  end

  def erase_compiled_data
    index_begin = self.source_tree.index {|s| s[1] == Config::BEGIN_FLAG}
    index_end   = self.source_tree.index {|s| s[1] == Config::END_FLAG}
    if index_end && index_begin
      self.source_tree =
        self.source_tree[0..index_begin-2]+self.source_tree[index_end+1..-1]
    end
  end

  def retreive_dir(repo, name)
    dir = ((repo == :local) ? REP_PATH : CUSTOM_PATH).addSlash
    dir + name.addSlash
  end

  def retreive_schema(repo, name)
    retreive_dir(repo, name) + 'package.rb'
  end

  def make_description(pkg)
    ln = ("="*78) + "\n"
    l  = ("-"*78) + "\n"
    desc = "=begin\n#{ln}"
    desc += "#{pkg.name.upcase} - #{pkg.version}\n#{l}\n"
    desc += "\t" + pkg.description + "\n" + l
    pkg.authors.each do |nick, email|
      desc += "\t#{nick} "
      desc += "<#{email}>" if email.length > 2
      desc += "\n"
    end
    desc += ln
    desc += "=end\n"
    desc
  end

  def pack(repo, type, name)
    package = FileTools.eval_file(retreive_schema(repo, name))
    compiled = PACK.new(repo, type, make_description(package), package.components)
    package.dependancies.each do |dep|
      pack(:local, type, dep)
    end
    self.compiled_data[name] = compiled
  end

  def compile_packages
    self.compiled_data = {}
    Builder.schema_final.each do |repo, type, name|
      pack(repo, type, name)
      Console.success "\t#{name} is compiled\n"
    end
  end

  def init(dev = false)
    self.dev          = dev
    self.output       = SCRIPT_RVDATA
    self.source_tree  = load_data(self.output)
    erase_compiled_data
    self.max_id       = self.source_tree.max_by { |s| s[0] || 0 }[0]
    Console.success "\tPosition is computed\n"
    compile_packages
  end

  def append_line(title, content)
    self.max_id += 1
    self.bytes << [self.max_id, title, deflate(content)]
  end

  def make_bytes
    self.bytes = []
    empty_script_line
    append_line(Config::BEGIN_FLAG, "")
    self.compiled_data.each do |name, struct|
      way = retreive_dir(struct.repo, name)
      if struct.type == :inline
        content = struct.desc + "\n"
        struct.composants.each do |f|
          if self.dev
            file_dir = File.absolute_path(way+f)
            content += "Kernel.send(:require, '#{file_dir}')\n".dup.force_encoding('utf-8')
          else
            content += FileTools.read(way+f) + "\n"
          end
        end
        append_line("#{Config::INLINE_CHAR} #{name.upcase}", content)
      else
        append_line("#{Config::EXTENDED_CHAR} #{name.upcase}", struct.desc)
        struct.composants.each do |f|
          if self.dev
            file_dir = File.absolute_path(way+f)
            content = "Kernel.send(:require, '#{file_dir}')\n".dup.force_encoding('utf-8')
          else
            content = FileTools.read(way+f)
          end
          append_line("-#{f}", content)
        end
      end
      Console.success "\t#{name} is merged\n"
    end
    append_line(Config::END_FLAG, "")
  end

  def make_rvdata
    junction = self.source_tree.index {|s| s[1] == Kernel.position}
    content = self.source_tree[0..junction] + self.bytes + self.source_tree[(junction+1)..-1]
    save_data(content, self.output)
    Console.success "\n\nRVDATA is builded\n"
  end

  def start(dev = false)
    init(dev)
    make_bytes
    make_rvdata
  end

end

module Kernel

  def insert_after(x)
    Package.s_insert_after = x
  end

  def position
    Package.s_insert_after || 'Scene_Gameover'
  end
end
