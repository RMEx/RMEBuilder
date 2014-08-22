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
# ** Path
#------------------------------------------------------------------------------
#  Retrieve Information about path
#==============================================================================

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
