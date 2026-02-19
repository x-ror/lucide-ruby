# frozen_string_literal: true

require "erb"
require "active_support/core_ext/string/output_safety"

require_relative "lucide_ruby/version"
require_relative "lucide_ruby/configuration"
require_relative "lucide_ruby/errors"
require_relative "lucide_ruby/cache"
require_relative "lucide_ruby/icon"
require_relative "lucide_ruby/view_helpers"
require_relative "lucide_ruby/railtie" if defined?(Rails)

module LucideRuby
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
      cache.clear!
    end

    def cache
      @cache ||= Cache.new
    end
  end
end
