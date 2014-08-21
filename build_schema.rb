# -*- coding: utf-8 -*-


project_directory "../Project1/"
insert_after "Scene_Gameover"

# Define a library
library("RME", '../Example/src') do 
  
  define_version 1, 0, 0
  describe "RME is a powerful tool to improve your RPGMaker VXAce experience!"

  add_author "Nuki", "xaviervdw@gmail.com"
  add_author "Hiino"
  add_author "Raho"
  add_author "Grim", "grimfw@gmail.com"

  add_component "RME.SDK",            "SDK.rb"
  add_component "RME.EvEx",           "EvEx.rb"
  add_component "RME.DocGenerator",   "DocGenerator.rb"
  add_component "RME.Documentation",  "Doc.rb"

  inline
end
