# -*- coding: utf-8 -*-
=begin
RMEBuilder
Copyright (C) 2014 Hiino
Copyright (C) 2014 Nuki <xaviervdw AT gmail DOT com>
Copyright (C) 2014 Grim <grimfw@gmail.com>

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
#==============================================================================
# ** Library
#------------------------------------------------------------------------------
#  Library representation
#==============================================================================

class Library
  #--------------------------------------------------------------------------
  # * Error
  #--------------------------------------------------------------------------
  MISMATCH    = lambda{|n| "#{n} not found"}
  MISVERSION  = lambda do |n, va, vb| 
    "#{n} not up to date (#{va.to_s} gived, #{vb.to_s} required)"
  end
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self

    attr_accessor :all
    attr_accessor :stack_error
    attr_accessor :project_dir
    attr_accessor :insert_after
    attr_accessor :buffer

    Library::all          = Hash.new
    Library::stack_error  = Array.new
    #--------------------------------------------------------------------------
    # * Easy Access
    #--------------------------------------------------------------------------
    def [](name);     Library.all[name];              end
    def []=(n, k);    Library.all[n] = k;             end
    def compilable?;  Library.stack_error.length == 0; end
    def each_keys
      keys = []
      Library.all.each do |k, v|
        c = (!v.inline?) ? "▼" : "■"
        keys << "■" + ' ' + k
        keys << "▼" + ' ' + k
        keys += v.childs.keys
      end
      keys
    end
  end

  #--------------------------------------------------------------------------
  # * Public Instances variables
  #--------------------------------------------------------------------------
  attr_reader :name
  attr_reader :version
  attr_reader :description
  attr_reader :dependencies
  attr_reader :dir
  attr_reader :childs
  attr_reader :authors
  attr_accessor :path

  #--------------------------------------------------------------------------
  # * Constructor
  #--------------------------------------------------------------------------
  def initialize(name, ldir, &block)
    @name         = name.dup.force_encoding('utf-8')
    @dir          = ldir
    @dependencies = Hash.new
    @childs       = Hash.new
    @authors      = Hash.new
    @inline       = false
    @path         = ''
    self.bind(&block)
    Library[name] = self
  end

  #--------------------------------------------------------------------------
  # * Define description
  #--------------------------------------------------------------------------
  def describe(desc)
    @description = desc.dup.force_encoding('utf-8')
  end

  #--------------------------------------------------------------------------
  # * Getter/Setter
  #--------------------------------------------------------------------------
  def version;  @version || vsn(1,0,0);       end
  def inline;   @inline = true;               end
  def inline?;  @inline;                      end

  #--------------------------------------------------------------------------
  # * Version
  #--------------------------------------------------------------------------
  def define_version(a = 1, b = 0, c = 0)
    @version = Kernel.version(a, b, c)
  end

  #--------------------------------------------------------------------------
  # * Add dependency
  #--------------------------------------------------------------------------
  def add_dependency(name, vsn = Kernel.version(1))
    @dependencies[name.dup.force_encoding('utf-8')] = vsn
    check_dependancies
  end
  alias_method :depends, :add_dependency

  #--------------------------------------------------------------------------
  # * Add component
  #--------------------------------------------------------------------------
  def add_component(name, path)
    @childs[name.dup.force_encoding('utf-8')] = path
  end
  alias_method :component, :add_component

  #--------------------------------------------------------------------------
  # * Add author
  #--------------------------------------------------------------------------
  def add_author(name, mail = nil)
    m = (mail.nil?) ? mail : mail.dup.force_encoding('utf-8')
    @authors[name.dup.force_encoding('utf-8')] = m
  end
  alias_method :author, :add_author

  #--------------------------------------------------------------------------
  # * Links data
  #--------------------------------------------------------------------------
  def bind(&block)
    @path = Library.buffer.dup || ''
    instance_eval(&block) if block_given?
  end

  #--------------------------------------------------------------------------
  # * Checlk dependencies
  #--------------------------------------------------------------------------
  def check_dependancies
    @dependencies.each do |n, vb|
      if Library[n]
        va = Library[n].version
        Library.stack_error << MISVERSION.call(n, va, vb) if va && va < vb
      else
        Library.stack_error << MISMATCH.call(n)
      end
    end
  end

end

#==============================================================================
# ** Kernel
#------------------------------------------------------------------------------
#  Common Interface
#==============================================================================

module Kernel

  def addslash(s)
    c = s[-1] == '/' ? '' : '/'
    s + c
  end
  
  def library(name, dir, &block)
    Library.new(name, dir, &block)
  end

  def project_directory(dir)
    Library.project_dir ||= addslash(dir)
  end

  def insert_after(n)
    Library.insert_after = n
  end

  def load_schema(*a, src)
    Library.buffer = (a[0]) ? addslash(a[0]) : ''
    Kernel.send(:load, TARGET_DIR + Library.buffer + src, true)
  end

end
