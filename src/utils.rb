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
  BEGIN_FLAG    = '[▼RMEBUILT]'
  END_FLAG      = '[▲RMEBUILT]'

end

class String

  def leven(other)
   n, m = self.length, other.length
   return m if n == 0
   return n if m == 0
   matrix  = Array.new(n+1) do |i|
     Array.new(m+1) do |j|
       if i == 0 then j
       elsif j == 0 then i
       else 0 end
     end
   end
   (1..n).each do |i|
     (1..m).each do |j|
       cost = (self[i] == other[j]) ? 0 : 1
       delete = matrix[i-1][j] + 1
       insert = matrix[i][j-1] + 1
       substitution = matrix[i-1][j-1] + cost
       matrix[i][j] = [delete, insert, substitution].min
       if (i > 1) && (j > 1) && (self[i] == other[j-1]) && (self[i-1] == other[j])
         matrix[i][j] = [matrix[i][j], matrix[i-2][j-2] + cost].min
       end
     end
   end
   return matrix.last.last
 end

 def words
   self.split(/,| |\.|\;|\:|\=|\!|\?/)
 end

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


end

#==============================================================================
# ** FileTools
#------------------------------------------------------------------------------
#  Tools for file manipulation
#==============================================================================

module FileTools
  extend self

  def write(file, str, flag = "w+")
    File.open(file, flag) {|f| f.write(str)}
  end

  def read(file)
    File.open(file, 'r') { |f| f.read }
  end

  def copy(src, dst)
    k = read(src)
    write(dst, k)
  end

  def move(src, dst)
    copy(src, dst)
    File.delete(src)
  end

  def safe_rmdir(d, v=false)
    if Dir.exist?(d)
      remove_recursive(d, v)
    end
  end

  def safe_mkdir(d)
    unless Dir.exist?(d)
      Dir.mkdir(d)
    end
  end

  def eval_file(f)
    return eval(read(f))
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

module Path
	extend self
	def waypoint(from, to)
		from 	= File.absolute_path(from).split(File::SEPARATOR)
		to 		= File.absolute_path(to).split(File::SEPARATOR)
		junc	= from.take_while do |elt|
			i = from.index(elt)
			elt == to[i]
		end
		before, after = *[from, to].map{|k| k - junc}
		result = (before.map{|_| '..'} + after).join(File::SEPARATOR)
		result
	end
end

module Doctor

  extend self

  def thematic_with(li, li2)
    (li && li2).length > 0
  end

  def thematic_hello(words)
    thematic_with(words, ['hello', 'ola', 'hi', 'goodmorning'])
  end

  def thematic_feel(words)
    thematic_with(words, ['feel', 'good', 'bad', 'sad', 'happy', 'alone'])
  end

  def thematic_family(words)
    thematic_with(words, ['parent', 'children', 'sister', 'brother', 'sisters', 'brothers', 'parents'])
  end

  def hash
    {
      hello:  ["Hi, how are you?", "Hello...", "Uhu"],
      feel:   ["What about you?", "It is your feeling ?", "Talk me about that?"],
      family: ["Is there problemes with him?", "Talk me about your family?", "Hmmm..."]
    }
  end

  def answer(question)
    words = question.words.map {|k| k.downcase}
    thematic = []
    thematic << :hello if thematic_hello(words)
    thematic << :feel if thematic_feel(words)
    thematic << :family if thematic_family(words)
    if Kernel.rand(2) == 0
      return "Oh, you say \"#{question}\"... how is your feeling about that?"
    else
      hash.each do |key, val|
        if Kernel.rand(2) == 0 && thematic.include?(key)
          return val.sample
        end
      end
    end
    return "Talk me about your Game ;)"
  end

end
