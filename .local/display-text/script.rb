# Affichage facile de texte
# Dépend de https://github.com/nukiFW/RPGMaker/tree/master/StandardizeRGSS
# Documentation : https://github.com/nukiFW/RPGMaker/tree/master/DisplayText
#==============================================================================
# ** TextProfile
#------------------------------------------------------------------------------
#  Représente un profil de mise en forme du texte
#==============================================================================

class TextProfile
  #--------------------------------------------------------------------------
  # * Singleton de TextProfile
  #--------------------------------------------------------------------------
  class << self 
    #--------------------------------------------------------------------------
    # * Profils enrigistrés 
    #--------------------------------------------------------------------------
    attr_accessor :registered
    TextProfile.registered ||= Hash.new
  end
  #--------------------------------------------------------------------------
  # * Variables d'instances
  #--------------------------------------------------------------------------
  attr_accessor :size
  attr_accessor :font
  attr_accessor :color
  attr_accessor :italic
  attr_accessor :bold
  attr_accessor :outline
  attr_accessor :outline_color
  attr_accessor :shadow
  attr_accessor :multiline
  #--------------------------------------------------------------------------
  # * Constructeur
  #--------------------------------------------------------------------------
  def initialize(*profile)
    if profile.length > 0
      val             = profile[0] 
      @size           = val.size
      @font           = val.font
      @color          = val.color
      @italic         = val.italic
      @bold           = val.bold
      @outline        = val.outline
      @outline_color  = val.outline_color
      @shadow         = val.shadow
      @multiline      =val.multiline
    else
      @size           = Font.default_size
      @font           = Font.default_name
      @color          = Font.default_color
      @italic         = Font.default_italic
      @bold           = Font.default_bold
      @outline        = Font.default_outline
      @outline_color  = Font.default_out_color
      @shadow         = Font.default_shadow 
      @multiline      = false
    end 
  end
  #--------------------------------------------------------------------------
  # * Sauvegarde un profile
  #--------------------------------------------------------------------------
  def register(name)
    TextProfile.registered[name.to_sym] = self
  end
  #--------------------------------------------------------------------------
  # * Convertit en objet font
  #--------------------------------------------------------------------------
  def to_font 
    f = Font.new
    f.name        = @font
    f.size        = @size
    f.bold        = @bold
    f.italic      = @italic
    f.outline     = @outline
    f.shadow      = @shadow
    f.color       = @color
    f.out_color   = @outline_color
    return f
  end
end

#==============================================================================
# ** Color
#------------------------------------------------------------------------------
#  Représente une couleur
#==============================================================================

class Color 
  #--------------------------------------------------------------------------
  # * Singleton de Color
  #--------------------------------------------------------------------------
  class << self 
    #--------------------------------------------------------------------------
    # * Couleurs enrigistrés 
    #--------------------------------------------------------------------------
    attr_accessor :registered
    Color.registered ||= Hash.new
  end
  #--------------------------------------------------------------------------
  # * Sauvegarde un profile
  #--------------------------------------------------------------------------
  def register(name)
    Color.registered[name.to_sym] = self
  end
end

#==============================================================================
# ** Kernel
#------------------------------------------------------------------------------
#  Ajout des méthodes de manipulation de profile et de couleurs
#==============================================================================

module Kernel 
  #--------------------------------------------------------------------------
  # * Récupération d'un TextProfile
  #--------------------------------------------------------------------------
  def get_profile(name)
    TextProfile.registered[name.to_sym] || TextProfile.registered[:default]
  end
  #--------------------------------------------------------------------------
  # * Récupération d'une couleur
  #--------------------------------------------------------------------------
  def get_color(name)
    Color.registered[name.to_sym] || Color.new(255,255,255)
  end
  #--------------------------------------------------------------------------
  # * Création d'un profil
  #--------------------------------------------------------------------------
  def create_profile(*args)
    TextProfile.new(*args)
  end
  #--------------------------------------------------------------------------
  # * Création d'une couleur
  #--------------------------------------------------------------------------
  def create_color(*args)
    Color.new(*args)
  end
end

#==============================================================================
# ** Game_Text
#------------------------------------------------------------------------------
#  Représentation d'un texte dynamiquement
#==============================================================================

class Game_Text 
  #--------------------------------------------------------------------------
  # * Variables d'instances
  #--------------------------------------------------------------------------
  attr_reader :number
  attr_reader :origin 
  attr_reader :x, :y 
  attr_reader :zoom_x, :zoom_y
  attr_reader :opacity
  attr_reader :angle
  attr_reader :blend_type
  attr_accessor :text_value 
  attr_accessor :profile 
  #--------------------------------------------------------------------------
  # * Constructeur
  #--------------------------------------------------------------------------
  def initialize(index)
    @profile = nil
    @number = index
    init_basic
    init_target
    init_rotate
  end
  #--------------------------------------------------------------------------
  # * Initialise les variables basiques
  #--------------------------------------------------------------------------
  def init_basic
    @text_value = ""
    @origin = @x = @y = 0
    @zoom_x = @zoom_y = 100.0
    @opacity = 255.0
    @blend_type = 1
  end
  #--------------------------------------------------------------------------
  # * Initialise le mouvement
  #--------------------------------------------------------------------------
  def init_target
    @target_x = @x
    @target_y = @y
    @target_zoom_x = @zoom_x
    @target_zoom_y = @zoom_y
    @target_opacity = @opacity
    @duration = 0
  end
  #--------------------------------------------------------------------------
  # * Initialise la Rotation
  #--------------------------------------------------------------------------
  def init_rotate
    @angle = 0
    @rotate_speed = 0
  end
  #--------------------------------------------------------------------------
  # * Affiche un texte à l'écran
  #--------------------------------------------------------------------------
  def show(text_value, profile, x, y, z_x = 100, z_y = 100, op = 255, bt = 0, ori = 0)
    @profile = profile
    @text_value = text_value.to_s
    @origin = ori
    @x = x.to_f
    @y = y.to_f
    @zoom_x = z_x.to_f
    @zoom_y = z_y.to_f
    @opacity = op.to_f
    @blend_type = bt
    init_target
    init_rotate
  end
  #--------------------------------------------------------------------------
  # * Déplacement du texte
  #--------------------------------------------------------------------------
  def move(duration, x = -1, y = -1, zoom_x = -1, zoom_y = -1, opacity = -1, blend_type = -1, origin = -1)
    @origin = origin unless origin == -1
    @target_x = x.to_f unless x == -1
    @target_y = y.to_f unless y == -1
    @target_zoom_x = zoom_x.to_f unless zoom_x == -1
    @target_zoom_y = zoom_y.to_f unless zoom_y == -1
    @target_opacity = opacity.to_f unless opacity == -1
    @blend_type = blend_type unless blend_type == -1
    @duration = duration
  end
  #--------------------------------------------------------------------------
  # * Change la rotation
  #--------------------------------------------------------------------------
  def rotate(speed)
    @rotate_speed = speed
  end
  #--------------------------------------------------------------------------
  # * Erase Picture
  #--------------------------------------------------------------------------
  def erase
    @text_value = ""
    @profile = nil
    @origin = 0
  end
  #--------------------------------------------------------------------------
  # * Modification a chaque frame
  #--------------------------------------------------------------------------
  def update
    update_move
    update_rotate
  end
  #--------------------------------------------------------------------------
  # * Modification du mouvement
  #--------------------------------------------------------------------------
  def update_move
    return if @duration == 0
    d = @duration
    @x = (@x * (d - 1) + @target_x) / d
    @y = (@y * (d - 1) + @target_y) / d
    @zoom_x  = (@zoom_x  * (d - 1) + @target_zoom_x)  / d
    @zoom_y  = (@zoom_y  * (d - 1) + @target_zoom_y)  / d
    @opacity = (@opacity * (d - 1) + @target_opacity) / d
    @duration -= 1
  end
  #--------------------------------------------------------------------------
  # * Modification de la rotation
  #--------------------------------------------------------------------------
  def update_rotate
    return if @rotate_speed == 0
    @angle += @rotate_speed / 2.0
    @angle += 360 while @angle < 0
    @angle %= 360
  end
end

#==============================================================================
# ** Game_Texts
#------------------------------------------------------------------------------
#  Représente la collection de textes
#==============================================================================

class Game_Texts
  #--------------------------------------------------------------------------
  # * Construction
  #--------------------------------------------------------------------------
  def initialize
    @data = []
  end
  #--------------------------------------------------------------------------
  # * Renvoi un text
  #--------------------------------------------------------------------------
  def [](number)
    @data[number] ||= Game_Text.new(number)
  end
  #--------------------------------------------------------------------------
  # * Iterator
  #--------------------------------------------------------------------------
  def each
    @data.compact.each {|text| yield text } if block_given?
  end
end

#==============================================================================
# ** Game_Screen
#------------------------------------------------------------------------------
#  Ajoute la gestion du texte
#==============================================================================

class Game_Screen
  #--------------------------------------------------------------------------
  # * Variables d'instances
  #--------------------------------------------------------------------------
  attr_reader :texts 
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias :displaytext_initialize :initialize
  alias :displaytext_update     :update
  #--------------------------------------------------------------------------
  # * Construction
  #--------------------------------------------------------------------------
  def initialize
    @texts = Game_Texts.new
    displaytext_initialize
  end
  #--------------------------------------------------------------------------
  # * Nettoyage de l'écran
  #--------------------------------------------------------------------------
  if !RPGMAKER.xp?
    alias :displaytext_clear :clear
    def clear
      displaytext_clear
      clear_texts
    end
  end
  #--------------------------------------------------------------------------
  # * Nettoyage des textes
  #--------------------------------------------------------------------------
  def clear_texts
    @texts.each{|t|t.erase}
  end
  #--------------------------------------------------------------------------
  # * Modification a chaque frame
  #--------------------------------------------------------------------------
  def update
    displaytext_update
    update_texts
  end
  #--------------------------------------------------------------------------
  # * Modification des textes
  #--------------------------------------------------------------------------
  def update_texts
    @texts.each{|t|t.update}
  end
end


#==============================================================================
# ** Sprite_Text
#------------------------------------------------------------------------------
#  Représente la vue du texte
#==============================================================================

class Sprite_Text < Sprite
  #--------------------------------------------------------------------------
  # * Construction de l'objet
  #--------------------------------------------------------------------------
  def initialize(viewport, dynamic_text)
    super(viewport)
    @text = dynamic_text
    @text_value = ""
    @profile = nil
  end
  #--------------------------------------------------------------------------
  # * Libération
  #--------------------------------------------------------------------------
  def dispose
    bitmap.dispose if bitmap
    super
  end
  #--------------------------------------------------------------------------
  # * Modification à chaque frames
  #--------------------------------------------------------------------------
  def update
    super
    update_bitmap
    update_origin
    update_position
    update_zoom
    update_other
  end
  #--------------------------------------------------------------------------
  # * Création du bitmap
  #--------------------------------------------------------------------------
  def create_bitmap 
    font = @text.profile.to_font
    bmp = Bitmap.new(1,1)
    bmp.font = font
    unless @text.profile.multiline 
      rect = bmp.text_size(@text_value) 
      self.bitmap = Bitmap.new(rect.width+32, rect.height)
      self.bitmap.font = font 
      self.bitmap.draw_text(0, 0, rect.width+32, rect.height, @text_value, 0)
    else
      # Création d'une boite multiligne
      lines = @text_value.split("\n")
      widths = Array.new
      heights = Array.new
      lines.each do |line| 
        r = bmp.text_size(line)
        widths << r.width
        heights << r.height
      end
      width, height = widths.max, heights.max
      total_height = height * lines.length
      self.bitmap = Bitmap.new(width+32, total_height)
      self.bitmap.font = font 
      iterator = 0
      lines.each do |line|
        self.bitmap.draw_text(0, iterator, width+32, height, line, 0)
        iterator += height
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Modification du transfert de l'image
  #--------------------------------------------------------------------------
  def update_bitmap
    if @text.text_value.empty?
      self.bitmap = nil
      @text_value = ""
    else
      if @text.text_value != @text_value || @profile != @text.profile
        @profile = @text.profile
        @text_value = @text.text_value
        if self.bitmap && !self.bitmap.disposed?
          self.bitmap = nil
        end
        create_bitmap
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Modification de l'origine
  #--------------------------------------------------------------------------
  def update_origin
    if @text.origin == 0
      self.ox = 0
      self.oy = 0
    else
      self.ox = bitmap.width / 2
      self.oy = bitmap.height / 2
    end
  end
  #--------------------------------------------------------------------------
  # * Update Position
  #--------------------------------------------------------------------------
  def update_position
    self.x = @text.x
    self.y = @text.y
    self.z = @text.number
  end
  #--------------------------------------------------------------------------
  # * Update Zoom Factor
  #--------------------------------------------------------------------------
  def update_zoom
    self.zoom_x = @text.zoom_x / 100.0
    self.zoom_y = @text.zoom_y / 100.0
  end
  #--------------------------------------------------------------------------
  # * Update Other
  #--------------------------------------------------------------------------
  def update_other
    self.opacity = @text.opacity
    self.blend_type = @text.blend_type
    self.angle = @text.angle
  end
end

#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  Ajout de la vue des textes
#==============================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias :displaytext_initialize :initialize
  alias :displaytext_dispose    :dispose
  alias :displaytext_update     :update
  #--------------------------------------------------------------------------
  # * Construction
  #--------------------------------------------------------------------------
  def initialize
    create_texts
    displaytext_initialize
  end
  #--------------------------------------------------------------------------
  # * Création des texts vierges
  #--------------------------------------------------------------------------
  def create_texts
    @text_sprites = Array.new
  end
  #--------------------------------------------------------------------------
  # * Libération
  #--------------------------------------------------------------------------
  def dispose
    displaytext_dispose
    dispose_texts
  end
  #--------------------------------------------------------------------------
  # * Libération des textes
  #--------------------------------------------------------------------------
  def dispose_texts
    @text_sprites.compact.each {|t| t.dispose }
  end
  #--------------------------------------------------------------------------
  # * Modification a chaque frame
  #--------------------------------------------------------------------------
  def update
    update_texts
    displaytext_update
  end
  #--------------------------------------------------------------------------
  # * Modification des texts
  #--------------------------------------------------------------------------
  def update_texts
    RGSS.screen.texts.each do |txt|
      @text_sprites[txt.number] ||= Sprite_Text.new(@viewport2, txt)
      @text_sprites[txt.number].update
    end
  end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  Ajout de l'API de manipulation des textes
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Affiche un text
  #--------------------------------------------------------------------------
  def text_show(id, *args)
    RGSS.screen.texts[id].show(*args)
  end
  #--------------------------------------------------------------------------
  # * Déplace un texte
  #--------------------------------------------------------------------------
  def text_move(id, duration, wait_flag, x = -1, y = -1, zoom_x = -1, 
      zoom_y = -1, opacity = -1, blend_type = -1, origin = -1)
    RGSS.screen.texts[id].move(
      duration, x, y, zoom_x, zoom_y, opacity, 
      blend_type, origin
    )
    if wait_flag
      wait(duration) if RPGMAKER.vxace?
      @wait_count = duration if RPGMAKER.vx?
    end
  end
  #--------------------------------------------------------------------------
  # * Supprime un texte
  #--------------------------------------------------------------------------
  def text_erase(id)
    RGSS.screen.texts[id].erase
  end
  #--------------------------------------------------------------------------
  # * Change un texte
  #--------------------------------------------------------------------------
  def text_change(id, value)
    RGSS.screen.texts[id].text_value = value
  end
  #--------------------------------------------------------------------------
  # * Change un profile
  #--------------------------------------------------------------------------
  def text_change_profile(id, profile)
    RGSS.screen.texts[id].profile = profile
  end
  #--------------------------------------------------------------------------
  # * Rotation
  #--------------------------------------------------------------------------
  def text_rotate(id, speed)
    RGSS.screen.texts[id].rotate(speed)
  end
  #--------------------------------------------------------------------------
  # * Change l'opacité
  #--------------------------------------------------------------------------
  def text_opacity(id, value)
    RGSS.screen.texts[id].opacity = value
  end
end

#--------------------------------------------------------------------------
# * Enregistrement du profile par défaut
#--------------------------------------------------------------------------
create_profile.register(:default)
#--------------------------------------------------------------------------
# * Enregistrement de couleurs par défaut
#--------------------------------------------------------------------------
create_color(255,255,255).register(:white)
create_color(255,0,0).register(:red)
create_color(0,255,0).register(:green)
create_color(0,0,255).register(:blue)
create_color(0,0,0).register(:black)