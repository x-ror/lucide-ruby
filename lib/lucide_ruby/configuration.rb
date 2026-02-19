# frozen_string_literal: true

module LucideRuby
  class Configuration
    attr_accessor :icon_path, :default_class, :default_size,
                  :default_stroke_width, :default_fill, :default_stroke,
                  :default_attributes

    def initialize
      @icon_path = nil
      @default_class = nil
      @default_size = 24
      @default_stroke_width = 2
      @default_fill = "none"
      @default_stroke = "currentColor"
      @default_attributes = {}
    end

    def resolved_icon_path
      @icon_path || default_icon_path
    end

    private

    def default_icon_path
      if defined?(Rails)
        Rails.root.join("app", "assets", "icons", "lucide").to_s
      else
        File.join(Dir.pwd, "app", "assets", "icons", "lucide")
      end
    end
  end
end
