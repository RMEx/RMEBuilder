# -*- coding: utf-8 -*-
=begin
RMEBuilder - Package
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

Utils.define_exception :UnboundPackage
Utils.define_exception :UndownloadPackage

class Package

  attr_accessor :name
  attr_accessor :version
  attr_accessor :components
  attr_accessor :dependancies
  attr_accessor :exclude
  attr_accessor :description
  attr_accessor :authors
  attr_accessor :uri
  attr_accessor :schema
  attr_accessor :assets

  def initialize(hash)
    @name         = hash[:name]
    @version      = hash[:version]      || vsn
    @components   = hash[:components]   || {}
    @dependancies = hash[:dependancies] || []
    @exclude      = hash[:exclude]      || []
    @authors      = hash[:authors]      || {}
    @description  = hash[:description]  || ""
    @assets       = hash[:assets]       || {}
  end

  def serialize
    "Package.new(name:#{@name}, version:#{@version}," +
    " dependancies:#{@dependancies}, authors: #{@authors}," +
    "description: #{@description})"
  end
end


module Packages
  class << self
    attr_accessor :all, :local, :custom, :cache_schema

      def exist?(name)
        list.has_key?(name) || custom.include?(name)
      end

      def get_local_schema(rep)
        local = Dir.glob(rep + '/*/package.rb').map do |file|
          name = file.split('/')[-2]
          schema = eval FileTools.read(file)
          [name, schema]
        end
        Hash[local]
      end
      def local; get_local_schema(REP_PATH); end
      def custom; get_local_schema(CUSTOM_PATH); end

      def download_schema(name)
        package = Packages.all[name]
        uri = package[:uri].clone
        uri << package[:schema]
        schema_content = uri.get
        schema = eval(schema_content)
      end

      def get_distant_schema(name)
        Packages.cache_schema[name] ||= download_schema(name)
      end

      def map
        list =
        Packages.list.map do |name, url|
          args    = url.split('/')
          schema  = args.pop
          uri     = args.join('/')
          [name, {uri: Http.service_with(uri), schema: schema}]
        end
        Packages.all = Hash[list]
      end

    end

    Packages.cache_schema = Hash.new
    Packages.map
end


class Package

  class << self
    attr_accessor :s_insert_after

    def merge_assets(package)
      if Packages.custom.has_key?(package)
        schema = Packages.custom[package]
        path = CUSTOM_PATH
      elsif Packages.local.has_key?(package)
        schema = Packages.local[package]
        path = REP_PATH
      else
        raise UndownloadPackage.new
      end
      puts ""
      path = path.addSlash + package.addSlash
      asset = path + 'assets/'
      schema.assets.each do |_, name|
        n = asset + base_name(name)
        name = name[1..-1] if name[0] == '/'
        dest = TARGET.addSlash + name
        FileTools.overkill_copy(n, dest)
        Console.success "\t#{name} is correctly copied "
      end
    end

    def base_name(url)
      url.split('/')[-1]
    end

    def true_name(url, uri)
      return url if url[/^(http(s)?|ftp)\:\/\//]
      f_uri = uri.clone
      f_uri << url
      f_uri.uri(true)
    end

    def exist?(name)
      Packages.exist?(name)
    end

    def download(name, target = REP_PATH, update = false, dep = target)
      raise UnboundPackage unless exist?(name)
      package = Packages.all[name]
      puts "\nDownload #{name}"
      Console.refutable "From #{Packages.list[name]}"
      FileTools.safe_mkdir(target)
      target = target.addSlash + name.addSlash
      target_assets = target + 'assets/'
      if update
        Console.warning "\tSuppress #{target} for redownload"
        begin
          FileTools.safe_rmdir(target)
        rescue Exception => exc
          p exc
        end
      else
        if Dir.exist?(target)
          Console.warning "\t#{target} already exist"
          puts ""
          return
        end
      end
      Console.success "\tCreate #{target}"
      Dir.mkdir(target)
      Console.success "\tCreate #{target_assets}"
      Dir.mkdir(target_assets)
      uri = package[:uri].clone
      uri << package[:schema]
      schema_content = uri.get
      FileTools.write(target + package[:schema], schema_content, 'w')
      Console.success "\tSchema is downloaded"
      schema = eval(schema_content)
      schema.components.each do |c_name|
        full_name = target + c_name
        init_uri = package[:uri].clone
        init_uri << c_name
        k = init_uri.get.dup.force_encoding('utf-8')
        FileTools.write(full_name, k, 'w')
        Console.success "\t#{full_name} is downloaded"
      end
      Console.success "\tRetreive assets"
      asset_error = 0
      schema.assets.each do |file, target_file|
        Console.refutable "\t download #{file} into #{target_assets}"
        asset = true_name(file, package[:uri])
        base_name = base_name(target_file)
        dest = target_assets + base_name
        begin
          Http.download_file(asset.dup, dest.dup)
          Console.success("\t#{file} is downloaded in #{dest}")
        rescue Exception => exc
          Console.alert("\t#{file} is not loaded for some reason")
          asset_error += 1
        end
      end
      if asset_error > 0
        Console.alert("\n\tAll assets couldn't be retreived")
      else
        Console.success("\n\tAll assets are downloaded")
      end
      resolve_dependancies(schema, dep, update)
      Console.success "\n#{name} is downloaded !\n"
      puts ""
    end

    def resolve_dependancies(schema, r, t)
      schema.dependancies.each {|pkg| download(pkg, r, t)}
    end

    def clone(name, update = false)
      download(name, CUSTOM_PATH, update, REP_PATH)
    end

    def get_info(name)
      unless exist?(name)
        return Console.alert "\n\t#{name} is not in the package stack.\n"
      end
      Console.warning "\n\tLocalisation:"
      if Packages.custom.include?(name)
        schema = Packages.custom[name]
        Console.refutable "\t " + File.realpath(CUSTOM_PATH) + "/#{name}"
      elsif Packages.local.include?(name)
        schema = Packages.local[name]
        Console.refutable "\t " + File.realpath(REP_PATH) + "/#{name}"
      else
        schema = Packages.get_distant_schema(name)
        Console.refutable "\t " + Packages.list[name]
      end
      colors = [14, 8]
      Console.two_colors "\n\tPackage name: ", schema.name, *colors
      Console.two_colors "\n\n\tDescription:", "\n\t #{schema.description}", *colors
      Console.warning "\n\n\tAuthors:"
      schema.authors.each do |nick, email|
        desc = "\t #{nick} "
        desc += "<#{email}>" if email.length > 2
        desc += "\n"
        Console.refutable desc
      end
      Console.warning "\n\tComponents:"
      schema.components.each do |c_name|
        Console.refutable "\t " + c_name
      end
    end

  end

end
