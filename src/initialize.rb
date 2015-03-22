# -*- coding: utf-8 -*-
=begin
RMEBuilder - Initialize
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

FW_LIST = Http::Service.new(
  prefix: 'raw.githubusercontent.com',
  port: 443,
  path: ['funkywork', 'RMEPackages', 'master', 'packages.rb']
)

module Sync
  extend self

  def from_funkywork
    header  = "\# Loaded from #{FW_LIST.uri(true)} at #{Time.now}\n"
    list    = FW_LIST.get
    File.open(REP_LIST, 'w') do |file|
      file.write(header + list)
    end
  end

end

def init
  FileTools.safe_mkdir(REP_PATH)
  Sync.from_funkywork
  Utils.load(REP_LIST)
end
init
