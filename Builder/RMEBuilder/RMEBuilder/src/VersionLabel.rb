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
# ** Version_Label
#------------------------------------------------------------------------------
#  Version representation
#==============================================================================

class Version_Label < Struct.new(:major, :sub, :last)
	#--------------------------------------------------------------------------
	# * to_s
	#--------------------------------------------------------------------------
	def to_s
	  "v #{self.major}.#{self.sub}.#{self.last}"
	end
	#--------------------------------------------------------------------------
	# * Compare operation
	#--------------------------------------------------------------------------
	def cmp(oth)
	  if oth.is_a?(Version_Label)
	    return -1 if oth.major > self.major
	    return  1 if oth.major < self.major
	    return -1 if oth.sub > self.sub
	    return  1 if oth.sub < self.sub
	    return -1 if oth.last > self.last
	    return  1 if oth.last < self.last
	    return 0
	  else raise RuntimeError.new("Must be a Version_Label")
	  end
	end
	#--------------------------------------------------------------------------
	# * Operators overloading
	#--------------------------------------------------------------------------
	def ==(o); self.cmp(o) == 0; end 
	def >(o);  self.cmp(o) > 0; end
	def <(o);  self.cmp(o) < 0; end 
	def >=(o); self.cmp(o) >= 0; end 
	def <=(o); self.cmp(o) <= 0; end
end

#==============================================================================
# ** Kernel
#------------------------------------------------------------------------------
#  Common Interface
#==============================================================================

module Kernel
  def version(a = 1, b = 0, c = 0)
    Version_Label.new(a, b, c)
  end
  alias_method :vsn, :version
end
