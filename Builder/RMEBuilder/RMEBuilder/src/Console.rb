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
# ** Console
#------------------------------------------------------------------------------
#  Console Handling
#==============================================================================

module Console
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  AllocConsole = Win32API.new('kernel32', 'AllocConsole', 'v', 'l')
  SetForegroundWindow = Win32API.new('user32', 'SetForegroundWindow','l','l')
  SetConsoleTitleA = Win32API.new('kernel32','SetConsoleTitleA','p','s')
  WriteConsoleOutput = Win32API.new('kernel32', 'WriteConsoleOutput', 'lpllp', 'l' )
  GetConsoleWindow = Win32API.new('kernel32','GetConsoleWindow', 'v', 'l')
  FindWindowA = Win32API.new('user32', 'FindWindowA', 'pp', 'i') 
  HANDLE = FindWindowA.call('RGSS Player', 0)

  extend self

  #--------------------------------------------------------------------------
  # * Console Init
  #--------------------------------------------------------------------------
  def init
    AllocConsole.call
    SetForegroundWindow.call(HANDLE)
    SetConsoleTitleA.call("RMEBuilder #{current_version.to_s}")
    $stdout.reopen('CONOUT$')
    $stdin.reopen('CONIN$')
  end
  #--------------------------------------------------------------------------
  # * Puts in console
  #--------------------------------------------------------------------------
  def print(*data)
    puts(*data.collect{|d|d.inspect})
  end
  #--------------------------------------------------------------------------
  # * Gets in console
  #--------------------------------------------------------------------------
  def gets
    SetForegroundWindow.call(GetConsoleWindow.call)
    $stdin.gets
  end

end

#==============================================================================
# ** Kernel
#------------------------------------------------------------------------------
#  Common Interface
#==============================================================================

module Kernel
  def p(*args); Console.print(*args); end
  def gets; Console.gets; end;  
end

# Run console
Console.init
