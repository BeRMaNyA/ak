require 'filewatcher'
require_relative 'ak/version'

module Ak
  extend self
  attr_accessor :root, :env

  class Registry
    attr_reader :files

    def initialize
      @files = []
    end

    def load(path, **options)
      path = get_path(path)

      file = Ak::HotFile.new(path, options)
      file.load_file

      files.push(file)
    end

    def find_by(type, value)
      files.find { |file| file.send(type) == value }
    end

    private

    def get_path(path)
      path = "#{path}.rb" unless path.match(/.rb$/)
      return path if path.include?(Ak.root)
      "#{Ak.root}/#{path}"
    end
  end

  class HotFile 
    attr_reader :name, :const, :descendants

    def initialize(name, **options)
      @name        = get_name(name)
      @const       = options[:const]
      @require     = options[:require]
      @descendants = []
    end

    def add_descendant(file)
      @descendants << file
    end

    def load_file
      require name if require_file?
      set_const unless const
      set_parents if const
    end

    def reload
      unload
      require name
      descendants.each &:reload
      true
    end

    def unload
      if const
        match = const.to_s.match(/\:\:(\w+)$/)

        if match
          parent = const.to_s.gsub("::#{match[1]}", '')
          Object.const_get(parent).send(:remove_const, match[1])
        else
          Object.send(:remove_const, const.to_s)
        end
      end

      $LOADED_FEATURES.delete(name)
    end

    def unload_and_reload
      unload and descendants.each(&:reload)
    end

    private

    def get_name(name)
      File.expand_path(name, Ak.root)
    end

    def set_const
      path = name.gsub(/#{Ak.root}\/|\.rb/, '').split('/')
      consts = path.map do |el|
        index = path.find_index { |_el| el == _el }
        Inflector.camelize path[index..(path.count)].join('/')
      end
      valid_const = nil
      
      consts.each do |const|
        valid_const = Object.const_get(const) rescue nil
        break if valid_const
      end

      @const = valid_const
    end

    def set_parents
      parents = const.ancestors.map do |ancestor|
        unless ancestor == const
          Ak.registry.find_by(:const, ancestor)
        end
      end.compact

      parents.each do |parent|
        parent.add_descendant(self)
      end
    end

    def require_file?
      @require && !$LOADED_FEATURES.include?(name)
    end
  end

  class Inflector
    def self.camelize(path)
      path.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
    end
  end

  def require(path, **options)
    return super path unless development?
    registry.load(path, options.merge(require: true))
  end

  def require_relative(path, **options)
    return super path unless development?
    caller_path = File.dirname(caller_locations.first.path)
    path = File.expand_path(path, caller_path)
    registry.load(path, options.merge(require: true))
  end

  def reload(path, **options)
    registry.load(path, options.merge(require: false))
  end

  def require_folders(*paths)
    get_files paths do |file|
      require_relative file
    end
  end

  def reload_folders(*paths)
    get_files paths do |file|
      reload file, options
    end
  end

  def start
    return unless development?

    dirs = registry.files.map { |file| File.dirname(file.name) }.uniq
    filewatcher = Filewatcher.new(dirs)

    Thread.new(filewatcher) do |filewatcher|
      filewatcher.watch do |filename, event| 
        begin
          puts "\n\n#{event.capitalize} #{filename.gsub("#{root}/", '')}\n\n"

          file = registry.find_by(:name, filename)

          if file
            file.load              if event == :created
            file.reload            if event == :updated
            file.unload_and_reload if event == :deleted
          else
            require(filename)
          end
        rescue Exception => e
          puts "\nError on event #{event}:\n#{'=' * 20}\n#{e}\n"
        end
      end
    end
  end

  def registry
    @registry ||= Registry.new
  end

  private

  def get_files(paths)
    pattern = paths.map { |path| "#{Ak.root}/#{path}/**/*" }
    Dir[*pattern].each { |file| yield(file) } 
  end

  def development?
    env == 'development'
  end
end
