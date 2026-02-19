# frozen_string_literal: true

module LucideRuby
  class Cache
    def initialize
      @store = {}
      @mutex = Mutex.new
    end

    def read(name)
      @mutex.synchronize { @store[name] }
    end

    def write(name, value)
      @mutex.synchronize { @store[name] = value }
    end

    def fetch(name)
      cached = read(name)
      return cached if cached

      value = yield
      write(name, value)
      value
    end

    def clear!
      @mutex.synchronize { @store.clear }
    end

    def size
      @mutex.synchronize { @store.size }
    end

    def preload!
      icon_path = LucideRuby.configuration.resolved_icon_path

      unless Dir.exist?(icon_path)
        raise IconsNotSynced.new(icon_path)
      end

      Dir.glob(File.join(icon_path, "*.svg")).each do |file|
        name = File.basename(file, ".svg")
        inner_html = Icon.extract_inner_html(File.read(file))
        write(name, inner_html)
      end

      size
    end
  end
end
