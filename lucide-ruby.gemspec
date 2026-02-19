# frozen_string_literal: true

require_relative "lib/lucide_ruby/version"

Gem::Specification.new do |spec|
  spec.name = "lucide-ruby"
  spec.version = LucideRuby::VERSION
  spec.authors = ["lucide-ruby contributors"]
  spec.summary = "Rails view helpers for rendering Lucide SVG icons inline"
  spec.description = "Provides Rails view helpers for rendering Lucide SVG icons inline. " \
                     "Icons are synced from official Lucide GitHub releases via a rake task."
  spec.homepage = "https://github.com/lucide-ruby/lucide-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*", "LICENSE.txt", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "actionview", ">= 6.0"
  spec.add_dependency "railties", ">= 6.0"
  spec.add_dependency "rubyzip", "~> 2.3"
end
