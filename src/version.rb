# -*- coding: utf-8 -*-
=begin
RMEBuilder - Version
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


Utils.define_exception :UnboundVersionException

class Version < Struct.new(:major, :sub, :last)

  def to_s
    "v #{major}.#{sub}.#{last}"
  end

  def compare(oth)
    raise UnboundVersionException unless oth.is_a?(Version)
    return -1 if oth.major  > major
    return  1 if oth.major  < major
    return -1 if oth.sub    > sub
    return  1 if oth.sub    < sub
    return -1 if oth.last   > last
    return  1 if oth.last   < last
    return  0
  end

  def ==(oth)
    compare(oth) == 0
  end

  def >(oth)
    compare(oth) > 0
  end

  def <(oth)
    compare(oth) < 0
  end

  def >=(oth)
    compare(oth) >= 0
  end

  def <=(oth)
    compare(oth) <= 0
  end

  def raw_inspect
    "vsn(#{major}, #{sub}, #{last})"
  end

end

module Kernel

    def vsn(a = 1, b = 0, c = 0)
      Version.new(a, b, c)
    end

end
