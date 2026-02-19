# frozen_string_literal: true

module LucideRuby
  class Railtie < Rails::Railtie
    initializer "lucide_ruby.view_helpers" do
      ActiveSupport.on_load(:action_view) do
        include LucideRuby::ViewHelpers
      end
    end

    rake_tasks do
      load File.expand_path("tasks/lucide.rake", __dir__)
    end
  end
end
