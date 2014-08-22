# -*- coding: utf-8 -*-
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