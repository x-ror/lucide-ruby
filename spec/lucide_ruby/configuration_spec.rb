# frozen_string_literal: true

require "spec_helper"

RSpec.describe LucideRuby::Configuration do
  describe "defaults" do
    subject(:config) { described_class.new }

    it "has nil icon_path" do
      expect(config.icon_path).to be_nil
    end

    it "has nil default_class" do
      expect(config.default_class).to be_nil
    end

    it "has default_size of 24" do
      expect(config.default_size).to eq(24)
    end

    it "has default_stroke_width of 2" do
      expect(config.default_stroke_width).to eq(2)
    end

    it "has default_fill of 'none'" do
      expect(config.default_fill).to eq("none")
    end

    it "has default_stroke of 'currentColor'" do
      expect(config.default_stroke).to eq("currentColor")
    end

    it "has empty default_attributes" do
      expect(config.default_attributes).to eq({})
    end
  end

  describe "#resolved_icon_path" do
    it "returns custom icon_path when set" do
      config = described_class.new
      config.icon_path = "/custom/path"
      expect(config.resolved_icon_path).to eq("/custom/path")
    end

    it "returns a default path when icon_path is nil" do
      config = described_class.new
      expect(config.resolved_icon_path).to include("app/assets/icons/lucide")
    end
  end

  describe "LucideRuby.configure" do
    it "allows configuration via block" do
      LucideRuby.configure do |config|
        config.default_class = "my-icon"
        config.default_size = 20
        config.default_stroke_width = 1.5
      end

      expect(LucideRuby.configuration.default_class).to eq("my-icon")
      expect(LucideRuby.configuration.default_size).to eq(20)
      expect(LucideRuby.configuration.default_stroke_width).to eq(1.5)
    end
  end

  describe "LucideRuby.reset_configuration!" do
    it "resets to defaults" do
      LucideRuby.configure { |c| c.default_class = "custom" }
      LucideRuby.reset_configuration!
      expect(LucideRuby.configuration.default_class).to be_nil
    end
  end
end
