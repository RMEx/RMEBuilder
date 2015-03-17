# Loaded from https://raw.githubusercontent.com/funkywork/RMEPackages/master/packages.rb at 2015-03-17 19:11:09 +0100
# List of RME Packages
module Packages
  extend self
  def list
    {
      'RME' => 'https://raw.githubusercontent.com/funkywork/RME/master/src/package.rb',
      'custom-database' => 'https://raw.githubusercontent.com/nukiFW/RPGMaker/master/CustomDatabase/package.rb'
    }
  end
end
