# Loaded from https://raw.githubusercontent.com/funkywork/RMEPackages/master/packages.rb at 2015-03-17 18:36:32 +0100
# List of RME Packages
module Packages
  extend self
  def list
    {
      'custom-database' => 
      	[
      		'https://raw.githubusercontent.com/nukiFW/RPGMaker/master/CustomDatabase',
      		'package.rb'
      	],
    }
  end
end
