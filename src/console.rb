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
  Alloc     = Win32API.new('kernel32', 'AllocConsole', 'v', 'l')
  SetFG     = Win32API.new('user32', 'SetForegroundWindow','l','l')
  SetTitle  = Win32API.new('kernel32','SetConsoleTitleA','p','s')
  Get       = Win32API.new('kernel32','GetConsoleWindow', 'v', 'l')
  Find      = Win32API.new('user32', 'FindWindowA', 'pp', 'i')
  SetCursor = Win32API.new('kernel32', 'SetConsoleCursorPosition', 'lp', 'l')
  SetColor  = Win32API.new('kernel32','SetConsoleTextAttribute','ll','l')
  GetHandle = Win32API.new('kernel32','GetStdHandle','l','l')
  Handle    = Find.call('RGSS Player', 0)

  extend self

  def init
    Alloc.call
    SetFG.call(Handle)
    SetTitle.call("RMEBuilder v2")
    $stdout.reopen('CONOUT$')
    $stdin.reopen('CONIN$')
    self.stdout = GetHandle.call(-11)
  end

  def print(*data)
    puts(*data.collect {|thing| thing.inspect})
  end

  def gets
    SetFG.call(Get.call)
    $stdin.gets
  end

  def clear
    system('cls')
  end

  def puts_color(txt, color)
    SetColor.call(stdout, color|0)
    puts txt
    SetColor.call(stdout, 0x000f|0)
  end

end

module Kernel

  def p(*args)
    Console.print(*args)
  end

  def gets
    Console.gets
  end

end

Console.init
