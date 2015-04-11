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

HWND = Win32API.new('user32', 'FindWindow', 'pp', 'i').call('RGSS Player', 0)

module Browser

  SHBrowseForFolder = Win32API.new('shell32', 'SHBrowseForFolderW', 'P', 'L')
  SHGetPathFromIDList = Win32API.new('shell32', 'SHGetPathFromIDListW', 'LP', 'L')
  CoTaskMemFree = Win32API.new('ole32', 'CoTaskMemFree', 'L', 'V')

  extend self
  def launch
    flags = 0x0000_0001|(0x0000_0010|0x0000_0040)
    d = [HWND, 0, 0, "Chose a project folder".to_wsc, flags, 0, 0, 0].pack('LLLpLLl')
    pidlist = SHBrowseForFolder.call(d)
    if pidlist == 0
      ''
    else
      path = Utils.alloc_buffer(260 * 2)
      r = SHGetPathFromIDList.call(pidlist, path)
      path.of_wsc
    end
  end

end

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

  def print_color(txt, color)
    SetColor.call(self.stdout, color|0)
    print txt
    SetColor.call(self.stdout, 0x0007|0)
  end

  def two_colors(a, b, ca, cb)
    SetColor.call(self.stdout, ca|0)
    print a
    SetColor.call(self.stdout, cb|0)
    print b
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

  def show_logo
    Kernel.sleep(0.5)
    load_rme =  '
                       ___          ___          ___
                      /\  \        /\  \        /\__\
                     /::\  \      |::\  \      /:/ _/_
                    /:/\:\__\     |:|:\  \    /:/ /\__\
                   /:/ /:/  /   __|:|\:\  \  /:/ /:/ _/_
                  /:/_/:/__/___/::::|_\:\__\/:/_/:/ /\__\
                  \:\/:::::/  /\:\~~\  \/__/\:\/:/ /:/  /
                   \::/~~/~~~~  \:\  \       \::/_/:/  /
                    \:\~~\       \:\  \       \:\/:/  /
                     \:\__\       \:\__\       \::/  /
                      \/__/        \/__/        \/__/ '
  load_builder = '
           __            _  __     __            ___      ___   ____
          / /_   __  __ (_)/ /____/ /___   _____|__ \    <  /  / __ \
         / __ \ / / / // // // __  // _ \ / ___/__/ /    / /  / / / /
        / /_/ // /_/ // // // /_/ //  __// /   / __/ _  / /_ / /_/ /
       /_.___/ \__,_//_//_/ \__,_/ \___//_/   /____/(_)/_/(_)\____/  '

  [0x0001, 0x0009, 0x0002, 0x000a, 0x000E, 0x000F, 0x000E, 0x000A].each do |i|
    clear
    SetColor.call(self.stdout, i)
    puts load_rme
    Kernel.sleep(0.05)
  end
  [0x0001, 0x0005, 0x000D, 0x000C].each do |i|
    clear
    SetColor.call(self.stdout,  0x000A)
    puts load_rme
    SetColor.call(self.stdout,  i)
    puts load_builder
    Kernel.sleep(0.05)
  end
  Kernel.sleep(0.5)
  puts "\n"
  SetColor.call(self.stdout, 0x0003)
  puts "             This software is a free software released under LGPL\n\n\n"
  puts "\n\n"
  Kernel.sleep(0.5)
  SetColor.call(self.stdout, 0x0007)
end

end

Console.init
