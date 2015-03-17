# CUSTOM DATABASE

# Système de base de données avancée (et flexible)
# Réalisé par Nuki (sur inspiration du travail de Avygeil et Grim)

# Produit deux bases de données, une statique et une dynamique
# Mappe le contenu de la base de données originale de RM

# (Les tables de la base de données sont potentiellement statiquement typées)

#==============================================================================
# ** Object
#------------------------------------------------------------------------------
#  Ajouts des métiers de conversions
#==============================================================================

class Object
  #--------------------------------------------------------------------------
  # * Conversion polymorphe (ne fait rien)
  #--------------------------------------------------------------------------
  def nothing; self; end
  alias :noth :nothing
  #--------------------------------------------------------------------------
  # * Conversion magique en booléen
  #--------------------------------------------------------------------------
  def db_cast_boolean
    return self if self.is_a?(TrueClass) || self.is_a?(FalseClass)
    return false unless self.respond_to?(:to_s)
    value = begin !!eval(self.to_s)
      rescue Exception => exc
        false
      end
  end
  alias :ptbo :db_cast_boolean
end

#==============================================================================
# ** Types
#------------------------------------------------------------------------------
#  Proposition d'un système de type minimaliste
#==============================================================================

module Types

  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Construit un type
    #--------------------------------------------------------------------------
    def make(type)
      return CommonDB::TYPES.find{|t|t.match(type)} if type.is_a?(Symbol)
      if type.is_a?(Array)
        return Types::Complex.new(:list, (make(type[1])))
      end
    end
    #--------------------------------------------------------------------------
    # * Inférence d'un type
    #--------------------------------------------------------------------------
    def inference(value)
      return :integer   if value.is_a?(Fixnum)
      return :float     if value.is_a?(Float)
      return :string    if value.is_a?(String)
      return :boolean   if value.is_a?(FalseClass) || value.is_a?(TrueClass)
      if value.is_a?(Array)
        v = value.compact
        return [:list, :poly] if v.length == 0 
        t = inference(v.first)
        return [:list, t] if v.all?{|x| inference(x) == t}
        return [:list, :poly]
      end
      return :poly
    end
  end

  #==============================================================================
  # ** Abstract
  #------------------------------------------------------------------------------
  #  Représentation abstraite d'un type
  #==============================================================================
  
  class Abstract
    #--------------------------------------------------------------------------
    # * Variables d'instances
    #--------------------------------------------------------------------------
    attr_accessor :coersion
    attr_accessor :name
    attr_accessor :names
    #--------------------------------------------------------------------------
    # * Constructeur
    #--------------------------------------------------------------------------
    def initialize(name, names, coer)
      @name     = name
      @names    = names 
      coersion  = coer
      if coer.is_a?(Symbol)
        coersion = Proc.new {|x| x.send(coer)}
      end
      @coersion = coersion
    end
    #--------------------------------------------------------------------------
    # * Produit une conversion
    #--------------------------------------------------------------------------
    def cast(x)
      self.coersion.call(x)
    end
    #--------------------------------------------------------------------------
    # * Vérifie qu'un nom correspond au type
    #--------------------------------------------------------------------------
    def match(label)
      return true if label.to_sym ==  @name.to_sym
      return @names.include?(label)
    end
  end

  #==============================================================================
  # ** Simple
  #------------------------------------------------------------------------------
  #  Représentation concrète d'un type simple
  #==============================================================================

  class Simple < Abstract
    #--------------------------------------------------------------------------
    # * Variables d'instances
    #--------------------------------------------------------------------------
    attr_accessor :is_rgss
    #--------------------------------------------------------------------------
    # * Constructeur
    #--------------------------------------------------------------------------
    def initialize(name, names, coer, rgss = false)
      super(name, names, coer)
      @is_rgss = rgss
    end
    alias :rgss? :is_rgss
  end

  #==============================================================================
  # ** Complex
  #------------------------------------------------------------------------------
  #  Représentation concrète d'un type avec subtype
  #==============================================================================

  class Complex < Abstract
    #--------------------------------------------------------------------------
    # * Variables d'instances
    #--------------------------------------------------------------------------
    attr_accessor :subtype
    #--------------------------------------------------------------------------
    # * Constructeur
    #--------------------------------------------------------------------------
    def initialize(name, subtype)
      @subtype = subtype
      coersion = ->(subtype,x){x.collect{|y|subtype.cast(y)}}
      super(name, [], coersion.curry.call(@subtype))
    end
  end

end 

#==============================================================================
# ** CommonDB
#------------------------------------------------------------------------------
#  Fonctionnalités communes
#==============================================================================

module CommonDB
  #--------------------------------------------------------------------------
  # * Configuration
  #   Définition du préfixe des tables de la base de données originale
  #--------------------------------------------------------------------------
  RGSS_PREFIX = "VXACE_"
  #--------------------------------------------------------------------------
  # * Micro Structures
  #--------------------------------------------------------------------------
  EmbedData = Struct.new(:name, :const, :container)
  #--------------------------------------------------------------------------
  # * Information de typage
  #--------------------------------------------------------------------------
  TYPES = [
    Types::Simple.new(:integer,   [:int, :integer, :natural, :fixnum],    :to_i),
    Types::Simple.new(:float,     [:float, :double, :real, :numeric],     :to_f),
    Types::Simple.new(:string,    [:string, :text, :raw],                 :to_s),
    Types::Simple.new(:boolean,   [:bool, :boolean, :switch],             :ptbo),
    Types::Simple.new(:poly,      [:poly, :polymorphic, :script, :rgss],  :noth),
    # Types spéciaux (issu du RGSS)
    Types::Simple.new(:actor,     [:actor, :actors, :heroes, :people],    :to_i, true),
    Types::Simple.new(:map,       [:map, :maps, :game_map, :gamemap],     :to_i, true),
    Types::Simple.new(:klass,     [:klass, :actor_type, :classes, :klasses],:to_i, true),
    Types::Simple.new(:skill,     [:kill, :skills, :jutsu],               :to_i, true),
    Types::Simple.new(:item,      [:item, :items, :usable_item],          :to_i, true),
    Types::Simple.new(:weapon,    [:weapon, :weapons],                    :to_i, true),
    Types::Simple.new(:armor,     [:armor, :armors],                      :to_i, true),
    Types::Simple.new(:enemy,     [:enemy, :enemies, :opposant],          :to_i, true),
    Types::Simple.new(:troop,     [:troop, :group, :troops],              :to_i, true),
    Types::Simple.new(:state,     [:state, :statement, :states],          :to_i, true),
    Types::Simple.new(:animtation,[:animtation, :anim],                   :to_i, true),
    Types::Simple.new(:tileset,   [:tileset, :tilesets, :tile, :tiles],   :to_i, true),
    Types::Simple.new(:mapinfo,   [:mapinfo, :mapinfos, :infomap],        :to_i, true)
  ]
  #--------------------------------------------------------------------------
  # * Structures embarquables
  #--------------------------------------------------------------------------
  RGSS_EMBEDABLE = [
    EmbedData.new(:actor,       RPG::Actor,       load_data("Data/Actors.rvdata2")),
    EmbedData.new(:klass,       RPG::Class,       load_data("Data/Classes.rvdata2")),
    EmbedData.new(:skill,       RPG::Skill,       load_data("Data/Skills.rvdata2")),
    EmbedData.new(:item,        RPG::Item,        load_data("Data/Items.rvdata2")),
    EmbedData.new(:weapon,      RPG::Weapon,      load_data("Data/Weapons.rvdata2")),
    EmbedData.new(:armor,       RPG::Armor,       load_data("Data/Armors.rvdata2")),
    EmbedData.new(:enemy,       RPG::Enemy,       load_data("Data/Enemies.rvdata2")),
    EmbedData.new(:troop,       RPG::Troop,       load_data("Data/Troops.rvdata2")),
    EmbedData.new(:state,       RPG::State,       load_data("Data/States.rvdata2")),
    EmbedData.new(:animtation,  RPG::Animation,   load_data("Data/Animations.rvdata2")),
    EmbedData.new(:tileset,     RPG::Tileset,     load_data("Data/Tilesets.rvdata2")),
    EmbedData.new(:mapinfo,     RPG::MapInfo,     load_data("Data/MapInfos.rvdata2")),
  ]
  RGSS_TYPES = [
    :actor, :map, :klass, :item, :weapon, :armor, :enemy, :troop,
    :state, :animtation, :tileset, :mapinfo, :skills
  ]
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Accès à une ressource du RGSS
    #--------------------------------------------------------------------------
    def rgss_access(data, id)
      return load_data(sprintf("Data/Map%03d.rvdata2", id)) if data == :map
      ctn = RGSS_EMBEDABLE.find{|d|d.name == data}
      raise(RuntimeError, "Container invalide") unless ctn
      ctn.container[id]
    end
  end

  #==============================================================================
  # ** Table
  #------------------------------------------------------------------------------
  #  Représentation générique d'une table
  #==============================================================================

  class Table
    #--------------------------------------------------------------------------
    # * Singleton
    #--------------------------------------------------------------------------
    class << self
      #--------------------------------------------------------------------------
      # * Variables d'instances 
      #--------------------------------------------------------------------------
      attr_accessor :fields
      attr_accessor :classname
      attr_accessor :records
      attr_reader   :primary_key
      alias :schema :fields
      #--------------------------------------------------------------------------
      # * Heritage des vues
      #--------------------------------------------------------------------------
      def inherit(klass)
        unless klass.respond_to?(:schema)
          raise(ArgumentError, "La classe n'est pas une table")
        end
        klass.schema.each do |field, type|
          if type.is_a?(Symbol)
            self.send(type, field)
          else
            self.send(type[0], type[1], field)
          end
        end
        define_primary_key (klass.primary_key)
      end
      #--------------------------------------------------------------------------
      # * Insertion
      #--------------------------------------------------------------------------
      def insert(*args); self.new(*args); end
      #--------------------------------------------------------------------------
      # * Construction d'un champ typé et nommé
      #--------------------------------------------------------------------------
      def handle_field(type, name)
        @records    ||= Hash.new
        @classname  ||= self.to_s.to_sym
        @fields     ||= Hash.new
        @fields[name] = type
        self.instance_variable_set("@#{name}".to_sym, nil)
        if RGSS_TYPES.include?(type)
          accessor = Proc.new do
            instance_var = self.instance_variable_get("@#{name}".to_sym)
            CommonDB.rgss_access(type, instance_var) if instance_var
          end
          self.send(:define_method, name.to_sym, &accessor)
        else
          self.send(:attr_reader, name.to_sym)
        end
        self.send(:attr_writer, name.to_sym)
        return name
      end
      #--------------------------------------------------------------------------
      # * Embarque une liste
      #--------------------------------------------------------------------------
      def list(subtype, name)
        return self.handle_field([:list, subtype], name) if subtype.is_a?(Symbol)
        return self.handle_field(subtype, name)
      end
      #--------------------------------------------------------------------------
      # * Etablit la clé primaire
      #--------------------------------------------------------------------------
      def define_primary_key(key)
        if !@fields.has_key?(key)
          raise(ArgumentError, "Le champ n'existe pas")
        elsif RGSS_TYPES.include?(@fields[key])
          raise(ArgumentError, "Les champs RGSS ne peuvent être des primary_key") 
        else
          @primary_key = key
        end
      end
      alias :pk         :define_primary_key
      alias :define_pk  :define_primary_key
      #--------------------------------------------------------------------------
      # * Enumerable
      #--------------------------------------------------------------------------
      def length; @records.length; end
      def [](prk); @records[prk]; end
      def each(&block); @records.each(&block); end
      alias   :count  :length
      alias   :size   :length
      alias   :all    :records
      include Enumerable
      #--------------------------------------------------------------------------
      # * Construction des champs par types (et alias)
      #--------------------------------------------------------------------------
      TYPES.each do |type|
        self.send(:define_method, type.name, &->(x){handle_field(type.name, x)})
        type.names.select{|u|u != type.name}.each do |name|
          self.send(:alias_method, name, type.name)
        end
      end 
    end # == Fin du Singleton de Table ==
    #--------------------------------------------------------------------------
    # * Initialize souple
    #--------------------------------------------------------------------------
    def initialize(*args)
      self.class.records  ||= hash.new
      if args.length != self.class.fields.length
        msg = "#{self.class.classname}:
          #{args.length} donnés, #{self.class.fields.length} requis"
        raise(ArgumentError, msg) 
      end
      arr_fields = self.class.fields.to_a
      (0...args.length).each do |i|
        current     = args[i]
        name, typen = *arr_fields[i]
        type        = Types.make(typen)
        value       = type.cast(current)
        self.instance_variable_set("@#{name}".to_sym, value)
        index = self.send(self.class.primary_key)
        self.class.records[index] = self
      end
    end
  end # == Fin de Table ==
end # == Fin du module CommonDB ==

#==============================================================================
# ** Static
#------------------------------------------------------------------------------
#  Composante relative au traitement de la base de données statique
#==============================================================================

module Static 
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Variables d'instances
    #--------------------------------------------------------------------------
    attr_accessor :tables
    Static.tables ||= Hash.new
    private :tables=
    #--------------------------------------------------------------------------
    # * Accès rapide à une table
    #--------------------------------------------------------------------------
    def method_missing(*args)
      name = args[0]
      return Static.tables[name] if Static.tables[name]
      super(*args)
    end 
  end # == Fin du Singleton ==

  #==============================================================================
  # ** Table
  #------------------------------------------------------------------------------
  #  Table de la base de données statique
  #==============================================================================
  class Table < CommonDB::Table
    #--------------------------------------------------------------------------
    # * Singleton
    #--------------------------------------------------------------------------
    class << self
      #--------------------------------------------------------------------------
      # * Construit un champ en fonction d'une variable d'instance
      #--------------------------------------------------------------------------
      def dynamic_from_ivar(name, value)
        sym_name = name[1 .. -1].to_sym
        subtype = Types.inference(value)
        return handle_field(subtype, sym_name) if subtype.is_a?(Symbol)
        return list(subtype, sym_name) if subtype.is_a?(Array) && subtype.length == 2 
        return (poly sym_name)
      end
      #--------------------------------------------------------------------------
      # * Etablit la clé primaire
      #--------------------------------------------------------------------------
      def define_primary_key(key)
        super(key)
        Static.tables[self.classname] ||= self
      end
      alias :pk         :define_primary_key
      alias :define_pk  :define_primary_key
    end
  end # == Fin de Table ==

  #--------------------------------------------------------------------------
  # * Mapping de la base de données originale
  #--------------------------------------------------------------------------
  CommonDB::RGSS_EMBEDABLE.select{|g|![:map,:mapinfo].include?(g.name)}.each do
    |rgss_struct|
    # mappingb
    const   = rgss_struct.const
    datas   = rgss_struct.container
    datas   = datas.compact if datas.respond_to?(:compact)
    datas   ||= []
    prefix  = CommonDB::RGSS_PREFIX
    name  = "#{prefix}#{rgss_struct.name.upcase}".to_sym
    if datas.length > 0 
      elt = datas.max{|e| e.instance_variables.length}
      temp_class = Class.new(Static::Table) do 
        @classname = name
        elt.instance_variables.each do |value|
          ivar = elt.instance_variable_get(value)
          dynamic_from_ivar(value, ivar)
        end
        define_pk :id
      end
      storage = Object.const_set(name, temp_class)
      # remplissage
      datas.each do |r| 
        entries = Array.new
        storage.fields.each do |iv, t|
          val = r.instance_variable_get("@#{iv}")
          entries << val
        end
        storage.insert(*entries)
      end
    end 
  end # == Fin du mapping statique de la BDD ==
  #--------------------------------------------------------------------------
  # * Cas particulier des maps
  #--------------------------------------------------------------------------
  rgss_mapinfo  = RPG::MapInfo.new
  rgss_map      = RPG::Map.new(100, 100)
  name          = "#{CommonDB::RGSS_PREFIX}MAP".to_sym
  temp_class    = Class.new(Static::Table) do
    @classname = name
    define_pk integer :id
    [rgss_mapinfo,rgss_map].each do |elt|
      elt.instance_variables.each do |value|
        ivar = elt.instance_variable_get(value)
        dynamic_from_ivar(value, ivar)
      end
    end
  end # == Fin du mapping des maps ==
  storage = Object.const_set(name, temp_class)
  # Remplissage
  mapinfos = CommonDB::RGSS_EMBEDABLE.find{|d|d.name == :mapinfo}
  mapinfos.container.each do |i, v|
    entries = [i]
    [v, load_data(sprintf("Data/Map%03d.rvdata2", i))].each do |r|
      r.instance_variables.each do |iv|
        entries << r.instance_variable_get(iv)
      end
    end
    storage.insert(*entries)
  end

end # == Fin de Static ==

#==============================================================================
# ** Dynamic
#------------------------------------------------------------------------------
#  Composante relative au traitement de la base de données dynamique
#==============================================================================

module Dynamic

  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Variables d'instances
    #--------------------------------------------------------------------------
    attr_accessor :tables
    Dynamic.tables  ||= Hash.new
    #--------------------------------------------------------------------------
    # * Convertit la base de données en hash
    #--------------------------------------------------------------------------
    def to_hash
      data = Hash.new
      Dynamic.tables.each do |name, value|
        data[name] = Hash.new
        value.all.each do |primary, instance|
          data[name][primary] = instance.to_array
        end
      end
      data
    end
    #--------------------------------------------------------------------------
    # * Accès rapide à une table
    #--------------------------------------------------------------------------
    def method_missing(*args)
      name = args[0]
      return Dynamic.tables[name] if Dynamic.tables[name]
      super(*args)
    end 
  end # == Fin du Singleton ==

  #==============================================================================
  # ** Table
  #------------------------------------------------------------------------------
  #  Table de la base de données statique
  #==============================================================================
  class Table < CommonDB::Table
    #--------------------------------------------------------------------------
    # * Singleton
    #--------------------------------------------------------------------------
    class << self
      #--------------------------------------------------------------------------
      # * Supprime un champ
      #--------------------------------------------------------------------------
      def delete(pkvalue)
        self.records.delete(pkvalue)
      end
      #--------------------------------------------------------------------------
      # * Supprime selon un prédicat
      #--------------------------------------------------------------------------
      def delete_if(&block)
        self.records.delete_if(&block)
      end
      #--------------------------------------------------------------------------
      # * Vide la table
      #--------------------------------------------------------------------------
      def drop
        self.records = Hash.new
      end
      #--------------------------------------------------------------------------
      # * Etablit la clé primaire
      #--------------------------------------------------------------------------
      def define_primary_key(key)
        super(key)
        Dynamic.tables[self.classname] ||= self
      end
      alias :pk         :define_primary_key
      alias :define_pk  :define_primary_key
    end
    #--------------------------------------------------------------------------
    # * Convertit une instance en tableau
    #--------------------------------------------------------------------------
    def to_array
      data = Array.new
      self.class.fields.each do |name, type|
        data << self.instance_variable_get("@#{name}".to_sym)
      end
      data
    end
  end

end # == Fin de Dynamic ==

#==============================================================================
# ** DataManager
#------------------------------------------------------------------------------
#  Persistance des données
#==============================================================================

module DataManager
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Alias
    #--------------------------------------------------------------------------
    alias :db_make_save_contents    :make_save_contents
    alias :db_extract_save_contents :extract_save_contents
    alias :db_create_game_objects   :create_game_objects
    #--------------------------------------------------------------------------
    # * Create Game Objects
    #--------------------------------------------------------------------------
    def create_game_objects
      db_create_game_objects
      Dynamic.tables.each do |k, t|
        t.drop
      end
    end
    #--------------------------------------------------------------------------
    # * Ajout de sauvegarde de la base de données
    #--------------------------------------------------------------------------
    def make_save_contents
      contents = db_make_save_contents
      contents[:database] = Dynamic.to_hash
      contents
    end
    #--------------------------------------------------------------------------
    # * Ajout du chargement de la base de données
    #--------------------------------------------------------------------------
    def extract_save_contents(contents)
      db_extract_save_contents(contents)
      contents[:database].each do |k, f|
        f.each do |key, a|
          Object.const_get(k).insert(*a)
        end
      end
    end
  end
end
