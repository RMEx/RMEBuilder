# Outil de standardisation des RGSS 1 2 ET 3

# Configuration
module Config
  # Juste pour XP ou VX
  ENABLE_CONSOLE = true
  # Remplacer par :xp, :vx ou :vxace pour ne pas utiliser de déduction 
  # de version
  VERSION = false
end

#==============================================================================
# ** RPGMAKER
#------------------------------------------------------------------------------
# Utilitaires complémentaires
#==============================================================================

module RPGMAKER
  #--------------------------------------------------------------------------
  # * Rendu public des fonctions
  #--------------------------------------------------------------------------
  extend self
  #--------------------------------------------------------------------------
  # * Renvoi la version de RM
  #--------------------------------------------------------------------------
  def version
    ([:vx,:vxace,:xp].include?(Config::VERSION)) ? Config::VERSION : infer_version
  end
  #--------------------------------------------------------------------------
  # * Tente de déduire la version de RPG Maker
  #--------------------------------------------------------------------------
  def infer_version 
    return :vxace if RUBY_VERSION == "1.9.2"
    return :xp    if defined?(Hangup)
    return :vx    if RUBY_VERSION == "1.8.1"
    raise "Unknown RPG Maker Version"
  end
  #--------------------------------------------------------------------------
  # * Vérifie si le script appartient à une version 
  #--------------------------------------------------------------------------
  def vxace?; version == :vxace;  end
  def vx?;    version == :vx;     end
  def xp?;    version == :xp;     end
end

#--------------------------------------------------------------------------
# * Ecrasement
#--------------------------------------------------------------------------

if !RPGMAKER.vxace?

  #==============================================================================
  # ** Console
  #------------------------------------------------------------------------------
  #  Implémentation de la console RGSS
  #==============================================================================

  module Console 

    #--------------------------------------------------------------------------
    # * Bibliothèques
    #--------------------------------------------------------------------------
    AllocConsole        = Win32API.new('kernel32', 'AllocConsole', 'v', 'l')
    SetForegroundWindow = Win32API.new('user32', 'SetForegroundWindow','l','l')
    SetConsoleTitleA    = Win32API.new('kernel32','SetConsoleTitleA','p','s')
    WriteConsoleOutput  = Win32API.new('kernel32', 'WriteConsoleOutput', 'lpllp', 'l' )
    GetConsoleWindow    = Win32API.new('kernel32','GetConsoleWindow', 'v', 'l')
    #--------------------------------------------------------------------------
    # * Accès aux fonctions
    #--------------------------------------------------------------------------
    extend self
    #--------------------------------------------------------------------------
    # * Initialisation de la console
    #--------------------------------------------------------------------------
    def init
      return unless RGSS.from_editor?
      AllocConsole.call
      SetForegroundWindow.call(RGSS.handle)
      SetConsoleTitleA.call("RGSS Console")
      $stdout.reopen('CONOUT$')
      $stdin.reopen('CONIN$') 
    end
    #--------------------------------------------------------------------------
    # * Affiche dans la console
    #--------------------------------------------------------------------------
    def print(*data)
      puts(*data.collect{|d|d.inspect})
    end
    #--------------------------------------------------------------------------
    # * Saisie de la console
    #--------------------------------------------------------------------------
    def gets
      SetForegroundWindow.call(GetConsoleWindow.call)
      $stdin.gets
    end

  end

  #==============================================================================
  # ** Graphics
  #------------------------------------------------------------------------------
  #  Ajout des attributs de la console
  #==============================================================================
  module Kernel
    if ($TEST || $DEBUG) && Config::ENABLE_CONSOLE
      def p(*args); Console.print(*args); end
      def gets; Console.gets; end;
    end
  end

  if RPGMAKER.xp?
    Game_Interpreter  = Interpreter
    #==============================================================================
    # ** Graphics
    #------------------------------------------------------------------------------
    #  Ajout des attributs Width et Height
    #==============================================================================

    module Graphics
      #--------------------------------------------------------------------------
      # * Information sur la taille de la fenêtre
      #--------------------------------------------------------------------------
      def width;  640; end
      def height; 480; end
    end
  end
  #==============================================================================
  # ** Font
  #------------------------------------------------------------------------------
  #  Ajout d'attributs inutiles (mais qui ne provoque pas d'erreur dans des cas 
  #  de scripts "cross plateforms")
  #==============================================================================

  class Font
    #--------------------------------------------------------------------------
    # * Variables d'instances
    #--------------------------------------------------------------------------
    attr_accessor :outline
    attr_accessor :out_color
    attr_accessor :shadow if !RPGMAKER.vx?
    #--------------------------------------------------------------------------
    # * Variables de classes
    #--------------------------------------------------------------------------
    class << self
      attr_accessor :default_outline
      attr_accessor :default_out_color
      if !RPGMAKER.vx?
        attr_accessor :default_shadow 
        default_shadow      = false
      end
      default_outline     = false
      default_out_color   = Color.new(0,0,0)
    end
  end

end

#--------------------------------------------------------------------------
# * Implémentation des classes de VXAce
#--------------------------------------------------------------------------

if !RPGMAKER.vxace?
  #==============================================================================
  # ** SceneManager
  #------------------------------------------------------------------------------
  #  Propose un gestionnaire de scène à la RPG Maker VXAce
  #==============================================================================

  module SceneManager
    class << self
      attr_accessor :stack
      SceneManager.stack = Array.new
      #--------------------------------------------------------------------------
      # * Scène courrante
      #--------------------------------------------------------------------------
      def scene; $scene; end
      #--------------------------------------------------------------------------
      # * Détermine le type de la scène
      #--------------------------------------------------------------------------
      def scene_is?(scene_class)
        $scene.instance_of?(scene_class)
      end
      #--------------------------------------------------------------------------
      # * Transition direct
      #--------------------------------------------------------------------------
      def goto(scene_class)
        $scene = scene_class.new
      end
      #--------------------------------------------------------------------------
      # * Appel de scène
      #--------------------------------------------------------------------------
      def call(scene_class)
        SceneManager.stack.push($scene)
        SceneManager.goto(scene_class)
      end
      #--------------------------------------------------------------------------
      # * Retour à la scène précédente
      #--------------------------------------------------------------------------
      def return 
        $scene = SceneManager.stack.pop
      end
      #--------------------------------------------------------------------------
      # * Nettoye l'historique
      #--------------------------------------------------------------------------
      def clear 
        SceneManager.stack.clear
      end
      #--------------------------------------------------------------------------
      # * Quitte le jeu
      #--------------------------------------------------------------------------
      def exit
        $scene = nil
      end
    end
  end

end

#==============================================================================
# ** RGSS
#------------------------------------------------------------------------------
# Utilitaires complémentaires
#==============================================================================

module RGSS 
  #--------------------------------------------------------------------------
  # * Constantes
  #--------------------------------------------------------------------------
  FindWindowA = Win32API.new('user32', 'FindWindowA', 'pp', 'i')
  HANDLE = FindWindowA.call('RGSS Player', 0)
  #--------------------------------------------------------------------------
  # * Rendu public des fonctions
  #--------------------------------------------------------------------------
  extend self
  #--------------------------------------------------------------------------
  # * Vérifie si le jeu est lancé depuis l'éditeur
  #--------------------------------------------------------------------------
  def from_editor?
    $TEST || $DEBUG
  end
  #--------------------------------------------------------------------------
  # * Renvoi le Game_Screen courant
  #--------------------------------------------------------------------------
  def screen 
    if RPGMAKER.vxace?
      return ($game_party.in_battle ? $game_troop.screen : $game_map.screen) 
    end
    if RPGMAKER.vx?
      return ($game_temp.in_battle ? $game_troop.screen : $game_map.screen)
    end
    $game_screen
  end
  #--------------------------------------------------------------------------
  # * Renvoi la fenêtre de jeu
  #--------------------------------------------------------------------------
  def handle
    HANDLE
  end
end


if !RPGMAKER.vxace? && RGSS.from_editor? && Config::ENABLE_CONSOLE
  Console.init 
end