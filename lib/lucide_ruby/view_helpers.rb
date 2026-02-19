# frozen_string_literal: true

module LucideRuby
  module ViewHelpers
    def lucide_icon(name, **options)
      Icon.new(name, **options).render
    end
  end
end
