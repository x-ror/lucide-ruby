# frozen_string_literal: true

module LucideRuby
  class Error < StandardError; end

  class IconNotFound < Error
    def initialize(name, path)
      super("Lucide icon '#{name}' not found at #{path}")
    end
  end

  class IconsNotSynced < Error
    def initialize(path)
      super("Lucide icons not found at #{path}. Run `rake lucide:sync` to download icons.")
    end
  end

  class SyncError < Error; end
end
