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
Win32API.new('user32', 'DestroyWindow', 'i', 'i').call(HWND)

module Browser

  SHBrowseForFolder = Win32API.new('shell32', 'SHBrowseForFolderW', 'P', 'L')
  SHGetPathFromIDList = Win32API.new('shell32', 'SHGetPathFromIDListW', 'LP', 'L')
  CoTaskMemFree = Win32API.new('ole32', 'CoTaskMemFree', 'L', 'V')

  extend self
  def launch
    flags = 0x0000_0001|(0x0000_0010|0x0000_0040)
    d = [Console::GetConsole.call, 0, 0, "Chose a project folder".to_wsc, flags, 0, 0, 0].pack('LLLpLLl')
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
    SetColor.call(self.stdout, color)
    puts txt
    SetColor.call(self.stdout, 7)
  end

  def print_color(txt, color)
    SetColor.call(self.stdout, color)
    print txt
    SetColor.call(self.stdout, 7)
  end

  def two_colors(a, b, ca, cb)
    SetColor.call(self.stdout, ca)
    print a
    SetColor.call(self.stdout, cb)
    print b
    SetColor.call(self.stdout, 7)
  end

  def three_colors(a, b, c, ca, cb, cc)
    SetColor.call(self.stdout, ca)
    print a
    SetColor.call(self.stdout, cb)
    print b
    SetColor.call(self.stdout, cc)
    print c
    SetColor.call(self.stdout, 7)
  end

  def success(txt)
    puts_color(txt, 10)
  end

  def alert(txt)
    puts_color(txt, 12)
  end

  def warning(txt)
    puts_color(txt, 14)
  end

  def refutable(txt)
    puts_color(txt, 8)
  end

  def show_logo
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
               __            _  __     __            ___      _  __
              / /_   __  __ (_)/ /____/ /___   _____|__ \    | |/ /
             / __ \ / / / // // // __  // _ \ / ___/__/ /    |   /
            / /_/ // /_/ // // // /_/ //  __// /   / __/ _  /   |
           /_.___/ \__,_//_//_/ \__,_/ \___//_/   /____/(_)/_/|_|  '
  #http://patorjk.com/software/taag/#p=display&h=1&f=Slant&t=builder2.X

  [1, 9, 2, 10].each do |i|
    clear
    SetColor.call(self.stdout, i)
    puts load_rme
    Kernel.sleep(0.05)
  end
  [[14,1], [15,5], [14,13], [10,12]].each do |i|
    clear
    SetColor.call(self.stdout,  i[0])
    puts load_rme
    SetColor.call(self.stdout,  i[1])
    puts load_builder
    Kernel.sleep(0.05)
  end
  SetColor.call(self.stdout, 3)
  puts "\n        (#{CURRENT_VERSION}) This software is a free software released under LGPL\n\n\n\n\n"
  SetColor.call(self.stdout, 7)
  Sync.check_update
end

end

Console.init
