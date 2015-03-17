# -*- coding: utf-8 -*-
=begin
RMEBuilder - Utils
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


module Config

  INLINE_CHAR   = '■'
  EXTENDED_CHAR = '▼'

end

class String

  # End with /
  def addSlash
    c = self[-1] == '/' ? '' : '/'
    self + c
  end

  # Change a string for win32API
  def to_ws
    result = ""
    (0..self.size).each do |i|
      result += self[i, 1] + "\0" unless self[i] == "\0"
    end
    return result
  end

end

module Utils
  extend self

  # load an external library
  def load(file)
    Kernel.send(:require, SRC_PATH.addSlash + file)
  end

  # Return max integer values
  def max_int
    (2**(0.size * 8 -2) -1)
  end

  # Return max request size
  def max_request_size
    1024000
  end

  def define_exception(exception_name)
    Object.const_set(exception_name, Class.new(Exception))
  end

  def remove_recursive(dir, verbose=false)
    d = Dir.glob(dir.addSlash+'*')
    if d.length > 0
      d.each do |entry|
        if File.directory?(entry)
          remove_recursive(entry)
        else
          File.delete(entry)
          puts "Suppress #{entry}" if verbose
        end
      end
    else
      Dir.rmdir(dir)
      puts "Suppress #{dir}" if verbose
    end
    Dir.rmdir(dir)
    puts "Suppress #{dir}" if verbose
  end

end
