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

  attr_accessor :stdout, :handle
  Alloc     = Win32API.new('kernel32', 'AllocConsole', 'v', 'l')
  SetFG     = Win32API.new('user32', 'SetForegroundWindow','l','l')
  SetTitle  = Win32API.new('kernel32','SetConsoleTitleA','p','s')
  Get       = Win32API.new('kernel32','GetConsoleWindow', 'v', 'l')
  Find      = Win32API.new('user32', 'FindWindowA', 'pp', 'i')
  SetCursor = Win32API.new('kernel32', 'SetConsoleCursorPosition', 'lp', 'l')
  SetColor  = Win32API.new('kernel32','SetConsoleTextAttribute','ll','l')
  GetHandle = Win32API.new('kernel32','GetStdHandle','l','l')
  SetHandle = Win32API.new('kernel32', 'SetStdHandle', 'll', 'l')
  ScreenBuff= Win32API.new('kernel32','CreateConsoleScreenBuffer','nnpnp','l')
  Handle    = Find.call('RGSS Player', 0)

  extend self

  def init
    Alloc.call
    tmode = 0x80000000|0x40000000
    fmode = 0x00000001|0x00000002
    self.handle = ScreenBuff.call(tmode, fmode, nil, 0x00000001, nil)
    SetFG.call(Handle)
    SetTitle.call("RMEBuilder v2")
    STDOUT.reopen('CONOUT$')
    STDIN.reopen('CONIN$')
    SetHandle.call(-11, self.handle)
    SetHandle.call(-10, self.handle)
    #self.stdout = GetHandle.call(-11)
  end

  def print(*data)
    puts(*data.collect {|thing| thing.inspect})
  end

  def gets
    SetFG.call(Get.call)
    STDIN.gets
  end

  def clear
    system('cls')
  end

  def puts_color(txt, color)
    SetColor.call(self.handle, color|0)
    puts txt
    SetColor.call(self.handle, 0x0007|0)
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

module Kernel

  def p(*args)
    Console.print(*args)
  end

  def gets
    Console.gets
  end

end

Console.init
