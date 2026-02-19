# frozen_string_literal: true

module LucideRuby
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)
      desc "Creates a LucideRuby initializer"

      def copy_initializer
        template "initializer.rb", "config/initializers/lucide_ruby.rb"
      end

      def create_icon_directory
        empty_directory "app/assets/icons/lucide"
        create_file "app/assets/icons/lucide/.keep"
      end

      def show_next_steps
        say ""
        say "LucideRuby installed! Next steps:", :green
        say "  1. Run `rake lucide:sync` to download Lucide icons"
        say "  2. Use `lucide_icon(\"icon-name\")` in your views"
        say ""
      end
    end
  end
end
