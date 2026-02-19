# frozen_string_literal: true

module LucideRuby
  class Icon
    SVG_CONTENT_REGEX = /<svg[^>]*>(.*)<\/svg>/m

    attr_reader :name, :options

    def initialize(name, **options)
      @name = self.class.normalize_name(name)
      @options = options
    end

    def render
      inner_html = load_inner_html
      attributes = svg_attributes
      build_svg(inner_html, attributes)
    end

    def self.normalize_name(name)
      name.to_s.strip.downcase.tr("_", "-")
    end

    def self.extract_inner_html(svg_content)
      match = svg_content.match(SVG_CONTENT_REGEX)
      match ? match[1].strip : ""
    end

    private

    def load_inner_html
      LucideRuby.cache.fetch(name) do
        icon_path = LucideRuby.configuration.resolved_icon_path
        file_path = File.join(icon_path, "#{name}.svg")

        unless Dir.exist?(icon_path)
          raise IconsNotSynced.new(icon_path)
        end

        unless File.exist?(file_path)
          raise IconNotFound.new(name, file_path)
        end

        self.class.extract_inner_html(File.read(file_path))
      end
    end

    def svg_attributes
      config = LucideRuby.configuration
      attrs = {
        xmlns: "http://www.w3.org/2000/svg",
        width: config.default_size,
        height: config.default_size,
        viewBox: "0 0 24 24",
        fill: config.default_fill,
        stroke: config.default_stroke,
        "stroke-width": config.default_stroke_width,
        "stroke-linecap": "round",
        "stroke-linejoin": "round"
      }

      # Merge default_attributes from config
      attrs.merge!(config.default_attributes) if config.default_attributes.any?

      # Merge caller options
      caller_opts = options.dup

      # Handle size shorthand
      if caller_opts[:size]
        size = caller_opts.delete(:size)
        caller_opts[:width] = size
        caller_opts[:height] = size
      end

      # Handle class merging (append, don't replace)
      if caller_opts[:class] && config.default_class
        caller_opts[:class] = "#{config.default_class} #{caller_opts[:class]}"
      elsif config.default_class && !caller_opts.key?(:class)
        caller_opts[:class] = config.default_class
      end

      # Auto aria-hidden unless aria attributes provided
      has_aria = caller_opts.key?(:aria) ||
                 caller_opts.keys.any? { |k| k.to_s.start_with?("aria") }
      attrs[:"aria-hidden"] = "true" unless has_aria

      attrs.merge!(caller_opts)
      attrs
    end

    def build_svg(inner_html, attributes)
      attr_string = attributes.map { |k, v|
        if v.is_a?(Hash)
          v.map { |sub_k, sub_v| "#{k}-#{sub_k}=\"#{escape(sub_v.to_s)}\"" }.join(" ")
        else
          "#{k}=\"#{escape(v.to_s)}\""
        end
      }.join(" ")

      "<svg #{attr_string}>#{inner_html}</svg>".html_safe
    end

    def escape(value)
      ERB::Util.html_escape(value)
    end
  end
end
