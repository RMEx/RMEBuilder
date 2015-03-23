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
    SetColor.call(self.stdout,  0x000b|0)
    puts  '
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
    SetColor.call(self.stdout,  0x000d|0)
    Kernel.sleep(1)
    puts '
                __            _  __     __            ___      ____
               / /_   __  __ (_)/ /____/ /___   _____|__ \    / __ \
              / __ \ / / / // // // __  // _ \ / ___/__/ /   / / / /
             / /_/ // /_/ // // // /_/ //  __// /   / __/ _ / /_/ /
            /_.___/ \__,_//_//_/ \__,_/ \___//_/   /____/(_)\____/  '
    puts "\n"
    Kernel.sleep(1)
    SetColor.call(self.stdout, 0x000e|0)
    puts "             This software is a free software released under LGPL\n\n\n"
    puts "\n\n"
    Kernel.sleep(1)
    SetColor.call(self.stdout, 0x0007|0)
  end

end

Console.init
