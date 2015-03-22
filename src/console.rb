# -*- coding: utf-8 -*-
=begin
RMEBuilder - Console
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

module Console

  attr_accessor :stdout
  SetFG       = Win32API.new('user32', 'SetForegroundWindow','l','l')
  SetColor    = Win32API.new('kernel32','SetConsoleTextAttribute','ll','l')
  GetHandle   = Win32API.new('kernel32','GetStdHandle','l','l')
  GetConsole  = Win32API.new('kernel32', 'GetConsoleWindow', 'v', 'l')

  extend self

  def init
    self.stdout = GetHandle.call(-11)
    SetFG.call(GetConsole.call)
  end

  def clear
    system('cls')
  end

  def puts_color(txt, color)
    SetColor.call(self.stdout, color|0)
    puts txt
    SetColor.call(self.stdout, 0x0007|0)
  end

  def success(txt)
    puts_color(txt, 0x000a)
  end

  def alert(txt)
    puts_color(txt, 0x000c)
  end

  def warning(txt)
    puts_color(txt, 0x000e)
  end

  def refutable(txt)
    puts_color(txt, 0x0008)
  end

end

Console.init
