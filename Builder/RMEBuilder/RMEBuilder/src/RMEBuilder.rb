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
# ** RMEBuilder
#------------------------------------------------------------------------------
#  RPGMaker VX Ace scripts builder V 1.0.0
#  Powered by FUNKYWORK (http://funkywork.github.io)
#
#  ~ Hiino, Grim and Nuki 
#  With special thanks to Zeus81, Joke and Zangther 
#  Big kiss to Raho
#==============================================================================

# Erase RM Window
HANDLE = Win32API.new('user32', 'FindWindowA', 'pp', 'i').call('RGSS Player', 0)
ARGV   = Win32API.new("Kernel32", "GetCommandLine", "", "P").call.split
Win32API.new('user32','ShowWindow','ll','l').call(HANDLE, 0)

# Define RMEBuilder version
def current_version; version(1, 0, 0); end

# Include Libs
Kernel.send(:require, 'target.rb')
TARGET = TARGET_DIR + TARGET_FILE
Kernel.send(:require, 'src/Path.rb')
Kernel.send(:require, 'src/VersionLabel.rb')
Kernel.send(:require, 'src/Console.rb')
Kernel.send(:require, 'src/Library.rb')

# Get Assembly data
Kernel.send(:require, TARGET)

# Build Assembly Data
Kernel.send(:require, 'src/Compiler.rb')
Compiler.general_process
# End Process
p "Press [enter] to finish process"
gets
